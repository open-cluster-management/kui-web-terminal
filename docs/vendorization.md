# Vendorizing Release builds
This document describes the steps required to vendorize a `release-x.y` git branch in preparation for downstream builds.

NOTE: revisit the steps after Cachito support is in place for downstream builds

## Step 1: Setup a build environment on a RHEL server (kefir-node) for vendorization
Vendorized builds are made on a RHEL server setup by CICD team. Contact CICD team to get SSH access to the machine.

```
ssh kefir-node
scl enable rh-nodejs12 bash
cd kui-web-terminal
```

## Step 2: Merge Master changes into release branch

Normally, a `release-fast-forward` mechanism will keep `master` branch in lock-step with the `release-x.y` branch, so this step is automated. However, currently a number of artifacts are checked in explicitly into `release-x.y` stream for making them available to downstream builds that execute in a `air-gap` environment. This breaks the automatic fast-forwarding mechanism. We hope to revert to `fast-forwarding` once `Cachito` support is in place.

```
git fetch --all
git checkout master
git checkout release-x.y
git merge master
```
and resolve all git differences and merge them. 

## Step 3: Clean up the environment

```
make init
make clean-kui #  Removes package-lock.json
make download-clis
make download-plugins
rm -rf vendor/client/node_modules
rm -rf vendor/proxy/node_modules
rm -rf client/node_modules
rm -rf proxy/node_modules
```

Verify that `package-lock.json` is removed from both `client` and `proxy` directories. 

## Step 4: Build KUI components
Perform KUI build by executing

```
make install
make webpack
make headless
```
These build steps download required node modules from https://registry.npmjs.org/ into `client/node_modules` and `proxy/node_modules` directories.

## Step 5: Check file sizes and check-in node modules
`github.com` currently limits the size of files we can check-in to 100MB. Need to make sure that all `node_modules` files, `cli` binaries are smaller than 100MB. If they are larger, compress the files and check-in tgz files to fit the size.

### Find files larger than 100MB and compress them
```
find . -type f -size +90M
tar cvf <file.tgz> <target-file>
```

### Move npm modules into `vendor` tree. 

```
mv client/node_modules vendor/client/
mv proxy/node_modules vendor/proxy
```

### Review and add all files to git repo
```
git add -f downloads # -f will force check the files even if they are in .gitignore
git add -f plugin-downloads
git add --all
git commit -m <msg>
```

### push changes to remote with right git user configuration
Before you Push changes to remote, make sure 
1. Default git user info does not exists in `~/.gitconfig` on the build server
```cat ~/.gitconfig
[user]
[push]
	default = simple
[user]
	email =
	name =
```
2. set your LOCAL configurations to specify your email/user within the repo.
```
git config --local user.name <...> && git config --local
```
Now you can perform a `push` to make changes available on `remote`.

## Step 6(Optional): verify that the build can run in air-gap environment

To verify that all dependencies are properly captured by the build, you can simulate a air-gap registry scenario by temporarily setting npm registry to `localhost` (may require coordinating with other users on the build machine)

### Changing npm registry 
```
# view current npm registry
npm get registry

# Simulate air-gap npm registry
npm set registry https://localhost

# Restore default npm registry
npm set registry https://registry.npmjs.org/
```

### Restore npm modules
Move npm modules from vendor tree into application tree
```
mv vendor/client/node_modules client/node_modules/
mv vendor/proxy/node_modules proxy/node_modules/
```
### Rebuild kui in air-gap mode
Run the build steps from Step 4. 

```
make install
make webpack
make headless
```
If all required node modules are cached correctly, the build should work without errors.

NOTE: Be sure to update downstream `Dockerfile.in` file with steps to uncompress any files compressed in Step 5.