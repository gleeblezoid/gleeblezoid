# Overview

Starting with our SLI specifications, we need to identify what elements of the user journey to examine when gauging user happiness in relation to purchases of in-game currency.

As a user I want to be able to:
- quickly and reliably open the "Buy Stuff" UI so I can pick out my items for purchase
- pay for those items quickly and reliably
- be quickly and correctly notified that my purchase is complete
- see the correct new amount of in-game currency on my account shortly afterwards

Based on the above we can focus in on some main items from the SLI menu by thinking about how they relate to the happiness of our users:
- Latency: We want responses to get to the user quickly, if something takes too long to respond in their purchase flow then it will make the user unhappy.
- Availability: The user needs multiple components to be online for their user journey to be successful and failures would be frustrating.
- Correctness: Users are paying real money for items so any unexpected or incorrect information in their purchase flow will make them unhappy.
- Throughput: When the user makes a purchase their data will be processed as part of the billing work-flow and that being too slow will make users unhappy

We'll go through each stage of the user journey and identify how to implement the SLIs from the menu for each stage by diving into how to describe and measure the proportion of valid events served successfully. In doing so, our items from the SLI menu can be re-framed as follows:

- Latency: The proportion of valid requests served within a certain time threshold
- Availability: The proportion of valid requests served successfully
- Correctness: The proportion of valid data that produced correct output
- Throughput: The proportion of time where the data processing rate was faster than a threshold.

This list of SLIs won't apply in the same way to each part of our user journey. For example, measuring correctness and throughput is only relevant where data processing of some kind is involved. In addition, it may not be practical to apply monitoring for SLIs at every stage so some areas may be better left uncovered.

I'll step through our user journey and provide SLI implementations (along with supporting information and details) on the way.

First, the user needs to get to our "buy stuff" UI, the initial request to connect to the Google Play Store also occurs from the client at this stage.

This is part of our application and is only seen on the client side - monitoring the success of this process by actively having telemetry from the client places a performance overhead upon our app and also introduces complex problems in terms of processing data about the environment which are beyond our control and may not even be relevant to a given failure. Users may also be unhappy about the performance impact and the increased demand for sharing data. 

Better testing before deployment reduces impact without requiring active telemetry via use of synthetic clients and internal test teams. In addition, if we provide users with the ability to send feedback and crash reports easily from our app then we capture useful data from the few who have issues without unduly upsetting our user base at large.

A potential exception to the reservation on client-side monitoring here is that of occasions where all the information required is present within our own application and where generating and sending such data would have little performance impact. Examples of this include the response codes from `BillingClient.BillingResponseCode` with the exceptions of `SERVICE_DISCONNECTED`, `SERVICE_UNAVAILABLE`, `SERVICE_TIMEOUT`, and `	USER_CANCELED` which are all either non-specific in terms of root cause or explicitly caused by the user/network connection. 

There's no location on the original briefing for this exercise where such logs are collected so to include SLIs which would use such data I've used "our logging server" to refer to the point of measurement and disambiguate from the "server" shown in the original setup.

Next, the store should load the list of available products, including our in-game currency.

If our server is slow to provide the client with our list of SKU IDs or that request to our server fails then this will make the user unhappy as product details will not be requested from the Google Play Store and presented to the user. 

We can measure the latency and availability for this service as follows:

-  The proportion of /api/getSKUs requests that get a response sent within 1000ms, measured on our server
-  The proportion of /api/getSKUs requests that get a response containing a list of SKU IDs, measured on our server

I've chosen a time threshold of 1000ms as that's an industry average (see https://cloud.google.com/architecture/adopting-slos#latency_alerts) for read operations.

If we were to add a feature to our app whereby a valid bundle response to `getSkuDetails() ` logged an event on a server owned by us then we'd potentially be able to measure the time between the "buy stuff" UI being opened and the product details being presented.

It's still worth us measuring the response times on our own server so that we're in a position to increase user happiness via the elements of the user journey that we can control. If we found that the response times of our own requests in addition to the turnaround on SKU details from the Play Store was making a large portion of users unhappy then we could shift our definition of a valid response on our server to use a smaller time threshold and improve our performance (and user happiness) accordingly.

Checking that the response sent to the client actually contains a list of SKUs should be relatively easy to code and report on as a boolean value. It also has the advantage of being more informative than a standard response code in that we are less likely to report false positives (e.g. blank responses which contain a success response code).

Whether the user gets presented with the option to actually buy our in-game currency depends on the list of SKU IDs we provide from our server being correct, a successful SKU Details Request being sent to the Play Store, and a successful SKU Details Response being returned to the client. 

We could potentially measure correctness here as follows:
- The proportion of SKU Details Requests in which a bundle was received from the Play Store wherein the SKU IDs list lines up correctly to the data in the bundle response from a corresponding SKU Details response `skuDetailsList`, measured on our logging server.

The client device possesses all the information in this case and can report back with a true/false result to a server we set up to receive such information with little client overhead and without gathering data outside of our application. We are also not dependent on the 

Once a user has been presented with the store and chosen to purchase more in-game currency they start the purchase flow. If this request isn't successful then that will make our users unhappy so we should measure availabilityy.

We can measure the availability of the purchase flow process as follows:
- The proportion of `launchBillingFlow()` calls which receive a `BillingResponseCode` of `OK`, measured on our logging server




