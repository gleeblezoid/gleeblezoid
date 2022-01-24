Our most important user journey is the one that generates all our revenue: users buying in-game currency via in-app purchases. Requests to the Play Store are only visible from the client. 

We see between 0.1 and 1 completed purchase every second; this spikes to 10 purchases per second after the release of a new area as players try to meet its requirements

This assignment will be graded along two axes:

The set of SLIs you choose and what parts of the journey they do or don't cover.
The measurement strategies you choose and the justification for your choices.

Develop SLI implementations that cover this user journey to your satisfaction. Justify:

Your definitions of "good events" and "valid events" in your implementations.

The measurement methods used, and the trade-offs they involve.

Any parts of the journey you have chosen to leave uncovered.

> Proportion of valid requests served successfully
> e.g The proportion of billing responses that have a good response code measured at our server
> e.g The proportion of purchases that occur within x amount of time measured on our server

# SLI Specifications
As a user I want to:

- Be able to _quickly_ and _reliably_ open the "buy stuff" UI
- Choose the amount of in-game currency I want to buy
- Pay the correct amount for the items quickly 
- Be quickly and correctly notified of my purchase

As an engineer I know:

- Requests _to_ the Play Store are visible only from the client
- We do get status codes from the play store when a purchase is completed
- The Life of a purchase is:
  - Show the user what they can buy.
  - Launch the purchase flow for the user to accept the purchase.
  - Verify the purchase on your server.
  - Give content to the user, and acknowledge delivery of the content. 
  - Optionally, mark the item as - consumed so that the user can buy the item again.
- Order IDs are created every time a financial transaction occurs. Purchase tokens are generated only when a user completes a purchase flow.
- For one-time products, every purchase creates a new purchase token. Most purchases also generate a new Order ID. The exception to this is when the user is not charged any money, as described in Promo codes.
- To receive updates on purchases, you must also call setListener(), passing a reference to a PurchasesUpdatedListener. This listener receives updates for all purchases in your app.
- The launchBillingFlow() method returns one of several response codes listed in BillingClient.BillingResponseCode. Be sure to check this result to ensure there were no errors launching the purchase flow. A BillingResponseCode of OK indicates a successful launch.
- On a successful call to launchBillingFlow(), the system displays the Google Play purchase screen
- You must implement onPurchasesUpdated() to handle possible response codes. A successful purchase generates a Google Play purchase success screen.
  - A successful purchase also generates a purchase token, which is a unique identifier that represents the user and the product ID for the in-app product they purchased. Your apps can store the purchase token locally, though we recommend passing the token to your secure backend server where you can then verify the purchase and protect against fraud. This process is further described in the following section.
  - For consumables, the consumeAsync() method fulfills the acknowledgement requirement and indicates that your app has granted entitlement to the user. This method also enables your app to make the one-time product available for purchase again.
  - Google provide test tracks for apps and products in apps
  - When testing consumable products, we recommend testing a variety of situations, including the following:
    - A successful purchase where the user receives an item. With a license tester, you can use the Test instrument, always approves payment method.
    - A purchase where the payment method failed to be charged, and the user should not receive the item. With a license tester you can use the Test instrument, always declines payment method.
    - Ensure items can be purchased multiple times.
    - You should also verify that purchases are properly acknowledged
    - Monthly reporting is available to track purchasing patterns and ensure SLIs and SLOs are being implemented appropriately against activity

1. Choose SLIs from the SLI menu
   1. Latency
   2. Availability
   3. Correctness

2. Refine into an SLI Implementation
   1. Where is it measured?
   2. What does the SLI measure?
   3. What metrics should be included or excluded?
   4. Is there enough detail to implement this SLI?

3. Walk through the user journey and look for coverage gaps

4. Set aspirational SLO targets based on business needs
