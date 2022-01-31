In the previous assignment I went through a set of premises upon which I based the user journey followed by a set of SLI implementations. I will go back over those implementations and premises here to establish some SLO targets and measurement windows for them.

As a user I want to be able to:
- quickly and reliably open the "Buy Stuff" UI so I can pick out my items for purchase;
- pay for those items quickly and reliably;
- be quickly and correctly notified that my purchase is complete;
- see the correct new amount of in-game currency on my account shortly afterwards.

Based on the above we can focus in on some main items from the SLI menu by thinking about how they relate to the happiness of our users:
- Latency: We want responses to get to the user quickly, if something takes too long to respond in their purchase flow then it will make the user unhappy.
- Availability: The user needs multiple components to be online for their user journey to be successful and failures would be frustrating.
- Correctness: Users are paying real money for items so any unexpected or incorrect information in their purchase flow will make them unhappy.

These can be re-framed as follows:

- Latency: The proportion of valid requests served within a certain time threshold
- Availability: The proportion of valid requests served successfully
- Correctness: The proportion of valid data that produced correct output

First, the user needs to get to our "buy stuff" UI, the initial request to connect to the Google Play Store also occurs from the client at this stage. 

We decided that client-side instrumentation would be too affected by environmental factors beyond our control when looking into the UI loading on the client device. The failure modes here are too variable for us to base our SLI or SLO on (e.g. poor service in the area where the client is located).

Next, the store should load the list of available products, including our in-game currency.

If our server is slow to provide the client with our list of SKU IDs or that request to our server fails then this will make the user unhappy as product details will not be requested from the Google Play Store and presented to the user. 

We can measure the latency for this service as follows:

-  The proportion of `/api/getSKUs` requests that get a response sent within 1000ms, measured on our server.


I've chosen a time threshold of 1000ms as that's an industry average (see https://cloud.google.com/architecture/adopting-slos#latency_alerts) for read operations and fits with our average 0.1-1 transactions per second being served but lower would be better having examined the additional time lapse from the Play Store leg.

Latency issues here are more likely to be related to our own server infrastructure and we can see historical latency information on our load balancer from which to base our measurement windows. Given the spike in requests that occur when a new area is introduced to our game we should tailor our measurement windows to give us meaningful data against our release cycles and overall usage - latency is especially affected given the likelihood of infrastructure being overloaded at the flood of requests.

We might even want to shift to a different calibration of SLIs and SLOs for latency duing such events (especially if we have infrastructure especially set up to cope with those events).

Something like a rolling 4 week window to cover weekday/weekend patterns makes sense but we might want to bear seasonal patterns in mind across the year if, for example, our area releases happen every December.

The major coverage gap here is that of the Play Store - we're unable to affect the performance of the Play Store under heavier request load and should bear in mind that that leg of the user journey will affect the time taken between initial requests for SKUs and the return of a list.

Initial SLOs of 99.9% during normal operation and 99.5% during peak demand for the average latency would be resonable and allow for iteration while also accounting for additional load along with corresponding shifted SLOs for the tail leg (perhaps 99.5% and 99% respectively).

We can measure availability for this service as follows:

-  The proportion of `/api/getSKUs` requests that get a response containing a list of SKU IDs, measured on our server

We could potentially measure correctness here as follows:

- The proportion of SKU Details Requests in which a bundle was received from the Play Store wherein the SKU IDs list lines up correctly to the data in the bundle response from a corresponding SKU Details response `skuDetailsList`, measured on our logging server.

We can also measure availability via:

- The proportion of SKU Details Requests in which a bundle was received from the Play Store, measured on our logging server.

The client device possesses all the information in these last two cases and can report back with a true/false result to a server we set up to receive such information with little client overhead and without gathering data outside of our application. 

Note that we're measuring the content of the response as well as the presence of a response at all - but only in a very simplistic way. If some kind of hardware problem or coding issue cause the SKU list to be invalid (but still parsed as SKUs) then the Play Store would not return the list of products to the user. 

This is a fairly majoy coverage gap for the SLI but in the case of coding errors we should be catching those based on testing prior to release into production (especially given we can test track our app to verify the Play Store's response). In the case of data corruption caused by hardware problems - it's unlikely that a successful but incorrect response would occur so we could implement a soft failure condition here (e.g. using cached SKUs) and measure a quality SLI based on how often we end up having to use that cached data.

A soft failure which handled failed responses from our server would affect how often the Play Store responded with complete failures so we would need to adjust any SLOs based on SKU Details Requests following such a change.

SLOs of 99.9% on the above would balance innovation and reliabilty with enough error budget to make changes to product listings. This is a part of the user journey we likely want to make changes to in order to keep things fresh for our users and so we need space to update our product offerings (as well as maintaining reliability).

Once a user has been presented with the store and chosen to purchase more in-game currency they start the purchase flow. 

Assuming we send the contents of the response from the Play Store (containing the `Status Code: Order ID: Purchase Token`) in the `/api/completePurchase` request to our server we can implement an SLI for the availability of the purchase flow process as follows:

- The proportion of `launchBillingFlow()` calls which received a `BillingResponseCode` of `OK` and did not receive `SERVICE_DISCONNECTED`, `SERVICE_UNAVAILABLE`, `SERVICE_TIMEOUT`, or `USER_CANCELED`, measured on our server

This will not differentiate between failures caused by the Play Store and our own infrastructure but ultimately this is a coverage gap which we can respond to meaningfully via root cause analysis if an SLO violation occurs. 

Although there will be spikes in the number of requests we shouldn't see the kinds of impact from seasonal variance in these responses as we'd expect from latency so measuring this SLI in a rolling 4 week window (again to keep a fixed number of weekends in our window) makes sense. This is a long enough period to establish reasonable SLOs based on normal performance and capture major patterns, but also short enough to meaningfully iterate on and improve our service.

We probably want an initial SLO of about 99.95% here in order to be able to make minor improvements but overall keep this leg of the journey reliably working as expected and not be overly held back by issues caused on the Play Store side.

We can measure the availability of our own purchase verification flow via:

- The proportion of `/api/completePurchase` requests with a corresponding successful account update sent to the client, measured on our server.

Here we're checking that the user is having their account updated when they make a purchase - in other words, the availability of that service.

To measure the reliability of the data handling in our account updates we can measure correctness via:

- The proportion of incoming status codes to our `Update Account` process which have a corresponding valid outgoing status code to the client based on our testing process, measured on our server.

In the case of availability the failure modes are relatively straightforward - either account updates are happening or they are not, the gap here is in the accuracy of those updates based on their content (which we measure using the correctness SLI).

In the case of measuring correctness, we would need to implement this by testing the status code which goes into the `Update Account` step against the status code that goes to the client, and writing checks which test the output of the `Update Account` step against known good test input data.

It may be worth aggregating these into a single SLI, something like "In-Game Currency Updates", against which to set our SLOs for this part of the user journey. I suggest this because if either fail state occurs then users will have paid for a product (our in-game currency) and then either not receive it or receive it incorrectly on their accounts. We care a lot if this fails at all, and having a simpler indicator for error budgeting would be useful.

This is a major enough issue that we should have a small rolling measurement window (perhaps 1-2 weeks) to allow for swift course correction should an SLO violation occur and stricter SLO targets than we had earlier in our user journey. 

I would say SLO targets of 99.99% would be reasonable for this initially. We need reliability for this to remain very high for user happiness and trading off innovation space is necessary. 

Changes in code that underpin the data handling and updates on in-game accounts are the most likely root cause for failures in this part of the user journey and so regular small release and fixes are likely the best course (with correspondingly tight measurement windows for quick feedback). This does have a degree of advantage in that, because most of the problems here will be our own fault, we have less unknown ground for coverage gaps.

If we want to be able to introduce new features to this aspect of our game then we need to balance ambitious SLO targets (due to the potential high impact of problems) against the need to innovate - most likely with fast tight feedback loops, and continuous improvements to our pre-release testing.

This has taken us to the end of this particular user journey. I've used the term "initially" against proposing SLOs as we'd need to examine our incoming and historical data from the SLIs we've established in order to choose meaningful objectives over time. 

