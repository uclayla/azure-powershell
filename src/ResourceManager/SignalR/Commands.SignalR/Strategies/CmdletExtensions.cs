﻿using Microsoft.Azure.Commands.Common.Strategies;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Azure.Commands.SignalR.Strategies
{
    static class CmdletExtensions
    {
        /// <summary>
        /// Note: the function must be called in the main PowerShell thread.
        /// </summary>
        /// <param name="cmdlet"></param>
        /// <param name="createAndStartTask"></param>
        public static void StartAndWait<T>(
            this T cmdlet, Func<IAsyncCmdlet, Task> createAndStartTask)
            where T : PSCmdlet
            => new CmdletWrap<T>(cmdlet).CmdletStartAndWait(createAndStartTask);

        sealed class CmdletWrap<T> : ICmdlet
            where T : PSCmdlet
        {
            readonly T _Cmdlet;

            public string VerbsNew => VerbsCommon.New;

            public CmdletWrap(T cmdlet)
            {
                _Cmdlet = cmdlet;
            }

            public IEnumerable<KeyValuePair<string, object>> Parameters
            {
                get
                {
                    var psName = _Cmdlet.ParameterSetName;
                    return typeof(T)
                        .GetProperties()
                        .Where(p => p
                            .GetCustomAttributes(false)
                            .OfType<ParameterAttribute>()
                            .Any(a => a.ParameterSetName == psName))
                        .Select(p => new KeyValuePair<string, object>(p.Name, p.GetValue(_Cmdlet)));
                }
            }

            public void WriteVerbose(string message)
                => _Cmdlet.WriteVerbose(message);

            public bool ShouldProcess(string target, string action)
                => _Cmdlet.ShouldProcess(target, action);

            public void WriteObject(object value)
                => _Cmdlet.WriteObject(value);

            public void WriteProgress(
                string activity,
                string statusDescription,
                string currentOperation,
                int percentComplete)
                => _Cmdlet.WriteProgress(
                    new ProgressRecord(
                        0,
                        activity,
                        statusDescription)
                    {
                        CurrentOperation = currentOperation,
                        PercentComplete = percentComplete,
                    });
        }
    }
}
