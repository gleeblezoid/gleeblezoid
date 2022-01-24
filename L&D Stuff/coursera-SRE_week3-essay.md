# Overview

Starting with our SLI specifications, we need to identify what elements of the user journey to examine when gauging user happiness in relation to purchases of in-game currency.

As a user I want to be able to:
- quickly and reliably open the "Buy Stuff" UI so I can pick out my items for purchase
- pay for those items quickly and reliably
- be quickly and correctly notified that my purchase is complete
- see the correct new amount of in-game currency on my account shortly afterwards

Based on the above we can focus in on some main items from the SLI menu:
- Latency: We want responses to get to the user quickly, if something takes too long to respond in their purchase flow then it will make the user unhappy.
- Availability: The user needs multiple components to be online for their user journey to be successful and failures would be frustrating.
- Correctness: Users are paying real money for items so any unexpected or incorrect information in their purchase flow will make them unhappy.
- Throughput: When the user makes a purchase their data will be processed as part of the billing work-flow and that being too slow will make users unhappy

We'll now go through each stage of the user journey and identify how to implement the SLIs from the menu for each stage by diving into how to describe and measure the proportion of valid events served successfully. In doing so, our items from the SLI menu can be re-framed as follows:

- Latency: The proportion of valid requests served within a certain time threshold
- Availability: The proportion of valid requests served successfully
- Correctness: The proportion of valid data that produced correct output
- Throughput: The proportion of time where the data processing rate was faster than a threshold.

This list of SLIs won't apply in the same way to each part of our user journey. For example, measuring correctness and throughput is only relevant where data processing of some kind is involved.

## Showing the user what they can buy



