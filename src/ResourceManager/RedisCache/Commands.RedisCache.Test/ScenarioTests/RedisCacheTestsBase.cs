﻿// ----------------------------------------------------------------------------------
//
// Copyright Microsoft Corporation
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ----------------------------------------------------------------------------------

namespace Microsoft.Azure.Commands.RedisCache.Test.ScenarioTests
{
    using System;
    using System.IO;
    using Microsoft.WindowsAzure.Commands.ScenarioTest;
    using Microsoft.WindowsAzure.Commands.Utilities.Common;
    using Microsoft.Azure.Test;
    using Microsoft.Azure.Management.Redis;
    using Microsoft.Azure.Common.Authentication;
    using WindowsAzure.Commands.Test.Utilities.Common;

    public abstract class RedisCacheTestsBase : RMTestBase, IDisposable
    {
        private EnvironmentSetupHelper helper;

        protected RedisCacheTestsBase()
        {
            helper = new EnvironmentSetupHelper();
        }

        protected void SetupManagementClients()
        {
            var redisManagementClient = GetRedisManagementClient();
            helper.SetupManagementClients(redisManagementClient);
        }

        protected void RunPowerShellTest(params string[] scripts)
        {
            using (UndoContext context = UndoContext.Current)
            {
                context.Start(TestUtilities.GetCallingClass(2), TestUtilities.GetCurrentMethodName(2));

                SetupManagementClients();

                helper.SetupEnvironment(AzureModule.AzureResourceManager);
                helper.SetupModules(AzureModule.AzureResourceManager, 
                    false, 
                    "ScenarioTests\\" + this.GetType().Name + ".ps1",
                    Path.Combine(helper.PackageDirectory, @"ResourceManager\AzureResourceManager\AzureRM.Profile\AzureRM.Profile.psd1"),
                    Path.Combine(helper.PackageDirectory, @"ResourceManager\AzureResourceManager\AzureRM.RedisCache\AzureRM.RedisCache.psd1")
                    );

                helper.RunPowerShellTest(scripts);
            }
        }

        protected RedisManagementClient GetRedisManagementClient()
        {
            return TestBase.GetServiceClient<RedisManagementClient>(new CSMTestEnvironmentFactory());
        }

        public void Dispose()
        {
        }
    }
}
