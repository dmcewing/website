---
title: Times Up Token
date: 2024-11-12
description: >
  
categories:
  - Development
  - C-Sharp
# links:
#   - setup/setting-up-a-blog.md
#   - plugins/blog.md
draft: false
---
# Times Up Token

During message processing sometimes a message triggers a function that can take a long time to execute.  One strategy to handle this
is to make the process able to retrigger itself after a fixed period of time.

In this example a single message is used to process a large number of update requests.

``` C# linenums="1" hl_lines="5 6 7 22 23 26 27 28 29 31"
bool timeout = false;
try
{
    //Timeout this block if it exceeds 15 minutes
    using (var timeoutCts = TimedCancellationSource.GetTimeoutToken())
    {
        using var combinedCts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken, timeoutCts.Token);

        //Get Details to process...
        await Parallel.ForEachAsync(details,
            new ParallelOptions()
            {
                CancellationToken = combinedCts.Token,
                MaxDegreeOfParallelism = 5,
            },
            async (detail, cancellationToken) =>
            {
                //Do process per detail here.
            }
        );

        if (!timeoutCts.Token.IsCancellationRequested)
            timeout = false; //We made it.
    }
} 
catch (OperationCanceledException)
{
    timeout = true;   //This will execute if either token is cancelled.
}

if (!cancellationToken.IsCancellationRequested) // So now check which token was cancelled.
{
    //Post message back for the next step.
}
```

The trick if you missed it is in the `TimedCancellationSource` and the combining of the two sources into `combinedCts`.  
The implementation of `TimedCancellationSource` (including interface for DI is below)

``` C# title="TimedCancellationSource"
namespace Fidelity.Tahi.IntermediaryTransfer.Services
{

    public interface ITimeoutTokenSource
    {
        CancellationTokenSource GetTimeoutToken();
    }

    public class TimeoutTokenSource : ITimeoutTokenSource
    {
        public CancellationTokenSource GetTimeoutToken() => new CancellationTokenSource(new TimeSpan(0, 15, 0));
    }

}
```

That is it.  You can of course change the parameters for the timespan on the token source or extend as needed.  For what I 
needed a 15 minute timeout was suiteable to allow enough time in setup and disposal to succeed within the 30 minute function timeout.
