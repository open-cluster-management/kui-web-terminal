/*
 * Copyright (c) 2020 Red Hat, Inc.
 */
/*
 * Copyright 2020 IBM Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import * as React from "react";
import { render } from "react-dom";
import {
  Kui,
  ContextWidgets,
  MeterWidgets,
} from "@kui-shell/plugin-client-common";
import {
  CurrentContext,
  CurrentNamespace,
} from "@kui-shell/plugin-kubectl/components";
import CustomSearchInput from "@kui-shell/plugin-search/mdist/components/CustomSearchInput"
import { ClusterUtilization } from "@kui-shell/plugin-kubectl/view-utilization";
import { ProxyOfflineIndicator } from "@kui-shell/plugin-proxy-support";
import { productName, connectSuccess } from '@kui-shell/client/config.d/name.json';

import { Card } from '@kui-shell/plugin-client-common'
import { REPL } from '@kui-shell/core'
//import KuiIcon from '../client-default/icons/png/WelcomeLight.png'


function loadingDone(repl: REPL) {
  return (
    <Card
      titleInHeader
      bodyInHeader
      title={connectSuccess}
      icon={require('../client-default/icons/png/WelcomeLight.png').default}
      //icon={KuiIcon}
      repl={repl}
    >
      To learn more, type `getting started`
    </Card>
  )
}

const wrapper = document.querySelector(".main");
if (wrapper) {
  render(
    <Kui bottomInput={<CustomSearchInput/>}
         productName={productName}
         //loadingDone={() => <pre>{connectSuccess}</pre>}
         loadingDone={loadingDone}
         noPromptContext
         prompt="&#x276f;"
         disableTableTitle
         sidecarName="heroText">
      <ContextWidgets>
        <CurrentContext />
        <CurrentNamespace />
      </ContextWidgets>

    </Kui>,
    wrapper
  );
}
