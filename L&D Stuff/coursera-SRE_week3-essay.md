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

We'll go through each stage of the user journey and identify how to implement the SLIs from the menu for each stage by diving into how to describe and measure the proportion of valid events served successfully. In doing so, our items from the SLI menu can be re-framed as follows:

- Latency: The proportion of valid requests served within a certain time threshold
- Availability: The proportion of valid requests served successfully
- Correctness: The proportion of valid data that produced correct output

I'll step through our user journey and provide SLI implementations (along with supporting information and details) on the way. For the purpose of providing a foundation to the implementation process, our in-game currency should be set up as a consumable item in the Play Store which is configured to support multi-quantity purchasing. This is mentioned now as it affects the responses available from the Play Store on which we might base our SLIs and also how any testing on this purchase journey would be done.

First, the user needs to get to our "buy stuff" UI, the initial request to connect to the Google Play Store also occurs from the client at this stage.

This is part of our application and is only seen on the client side - monitoring the success of this process by actively having telemetry from the client places a performance overhead upon our app and also introduces complex problems in terms of processing data about the environment which are beyond our control and may not even be relevant to a given failure. Users may also be unhappy about the performance impact and the increased demand for sharing data. 

Better testing before deployment reduces impact without requiring active telemetry via use of synthetic clients and internal test teams. In addition, if we provide users with the ability to send feedback and crash reports easily from our app then we capture useful data from the few who have issues without unduly upsetting our user base at large.

A potential exception to the reservation on client-side monitoring here is that of occasions where all the information required is present within our own application and where generating and sending such data would have little performance impact. Examples of this include the response codes from `BillingClient.BillingResponseCode` with the exceptions of `SERVICE_DISCONNECTED`, `SERVICE_UNAVAILABLE`, `SERVICE_TIMEOUT`, and `	USER_CANCELED` which are all either non-specific in terms of root cause or explicitly caused by the user/network connection. 

There's no location on the original briefing for this exercise where information from clients is collected so to include SLIs which would use such data I've used "our logging server" to refer to the point of measurement and disambiguate from the "server" shown in the original setup. I'm working under the assumption that we have an EULA and Privacy agreements set up already to allow the collection of such data.

Next, the store should load the list of available products, including our in-game currency.

If our server is slow to provide the client with our list of SKU IDs or that request to our server fails then this will make the user unhappy as product details will not be requested from the Google Play Store and presented to the user. 

We can measure the latency for this service as follows:

-  The proportion of /api/getSKUs requests that get a response sent within 1000ms, measured on our server


I've chosen a time threshold of 1000ms as that's an industry average (see https://cloud.google.com/architecture/adopting-slos#latency_alerts) for read operations.

If we were to add a feature to our app whereby a valid bundle response to `getSkuDetails() ` logged an event on a server owned by us then we'd potentially be able to measure the time between the "buy stuff" UI being opened and the product details being presented.

That said, it's worth us measuring the response times on our own server so that we're in a position to increase user happiness via the elements of the user journey that we can control. If we found that the response times of our own requests in addition to the turnaround on SKU details from the Play Store was making a large portion of users unhappy then we could shift our definition of a valid response on our server to use a smaller time threshold and improve our performance (and user happiness) accordingly.

We can measure availability for this service as follows:

-  The proportion of /api/getSKUs requests that get a response containing a list of SKU IDs, measured on our server

Checking that the response sent to the client actually contains a list of SKUs should be relatively easy to code and report on as a boolean value. It also has the advantage of being more informative than a standard response code in that we are less likely to report false positives (e.g. blank responses which contain a success response code).

Whether the user gets presented with the option to actually buy our in-game currency depends on the list of SKU IDs we provide from our server being correct, a successful SKU Details Request being sent to the Play Store, and a successful SKU Details Response being returned to the client. 

We could potentially measure correctness here as follows:

- The proportion of SKU Details Requests in which a bundle was received from the Play Store wherein the SKU IDs list lines up correctly to the data in the bundle response from a corresponding SKU Details response `skuDetailsList`, measured on our logging server.

We can also measure availability via:

- The proportion of SKU Details Requests in which a bundle was received from the Play Store, measured on our logging server.

The client device possesses all the information in these cases and can report back with a true/false result to a server we set up to receive such information with little client overhead and without gathering data outside of our application. 

Once a user has been presented with the store and chosen to purchase more in-game currency they start the purchase flow. If this request isn't successful then that will make our users unhappy so we should measure availability.

Once the Billing Flow is launched and the Play Store responds to the client we send an `/api/completePurchase` request to our server which contains the purchase details needed to process and verify the purchase of more in-game currency. 

Assuming we send the contents of the response from the Play Store (containing the `Status Code: Order ID: Purchase Token`) we can implement an SLI for the availability of the purchase flow process as follows:

- The proportion of `launchBillingFlow()` calls which received a `BillingResponseCode` of `OK` and did not receive `SERVICE_DISCONNECTED`, `SERVICE_UNAVAILABLE`, `SERVICE_TIMEOUT`, or `USER_CANCELED`, measured on our server

Although this SLI may end up skewed by issues which are not within our control (for example, if the Play Store suffers a problem which generates an `ERROR` response code) the elimination of responses which are likely to be more affected by the user's environment makes it more likely that a given failure is something we as app developers can fix (such as our in-game currency not being consumed properly or invalid arguments being presented to the Play Store API).

We then verify the purchase token from our server with the Play Store and receive a status code back before updating the user's account with their new in-game currency balance by giving them the currency they purchased and acknowledging the purchase with the `consumeAsync()` method.

We could measure the availability of our own purchase verification flow via:
- The proportion of verification requests in which a `Purchase Token` is successfully matched in a response to `Purchases.products:get`, on our server.

I'm not sure what that gets us in terms of user happiness metrics though - it's great for us to know about if something does go wrong, but what users actually experience is more related to them seeing purchases turn up on their account than the verification of their purchase token. 

I'd zoom out a little and look at what we're sending the client once we've verified the purchase and updated the account. In other words:

- The proportion of `/api/completePurchase` requests with a corresponding successful account update sent to the client, measured on our server.

Here we're checking that the user is having their account updated when they make a purchase - in other words, the availability of that service.

I'd also be tempted to measure the correctness of the data being handled in that account update. For example, when we receive a status code saying that a user has a valid purchase of 3 more in-game money are we then showing correctly that 3 more money has been added and that the item has been consumed so that the user can buy more?

We could implement this by testing the status code which goes into the `Update Account` step against the status code that goes to the client, and writing checks which test the output of the `Update Account` step against known good test input data.

In other words, we can measure correctness via:

- The proportion of incoming status codes to our `Update Account` process which have a corresponding valid outgoing status code to the client based on our testing process, measured on our server.

This has taken us to the end of this particular user journey but there's a little bit more to explore in looking at the journey as a whole and at future iterations on our current SLI implementations.

Although we've broken down the journey here to component parts we'd do well to implement end-to-end testing in the form of synthetic clients and potentially use the information from those tests to monitor our service better under times of high stress (such as after the release of a new game area) or in specific regions. 

This is distinct from standard integration testing as we're not simply checking that the code in our purchase process works, we're also looking into the effects of factors which will impact our customer base around the world and how to tailor our SLIs to those variables. If our servers are located only in the US, for example, then customers in EMEA will experience a higher level of latency than our US customers which we can only improve by setting up in an additional region. We'll need to adjust our service or our SLIs based on what makes sense for us at the time.

If we're seeing more traffic than usual then our previously less relevant checks on Purchase Tokens may be more necessary as additional stress is applied to the database on our server. We may need to monitor the throughput and coverage on our `Update Account` service as well in case the larger volume of requests reveals limitations in our setup which cause waiting periods that make users unhappy or even result in data processing failures.


