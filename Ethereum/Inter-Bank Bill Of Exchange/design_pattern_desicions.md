1) Circuit breaker is used to allow banks to halt Bill of Exchange transactions if something suspicious occured.
2) All transactions follow the withdrawal pattern to guard against re-entrancy and DoS
3) Auction design uses manual input (from the boe holder) to stop an Auction. Relying on time-based auctions is not used to reduce block.timestamp dependance.
4) send() is used instead of transfer() since I do not want the transaction to revert if payment fails, but rather serve as a signpost to start the auction.
5) now is used when certifying the Certificate of Inspection, but as it does not involve in any transactions it is relatively safe. It is merely used for information.
6) exerciseBillOfExchange() and certifyCertOfInspection() are payable to facilitate transactions between the parties --> For example, Importer will send money to the contract, which will send money back to the BOE Holder.
7) Contract has no fallback function to prevent accidental deposit of funds into the contract, making the contract hold no value apart from what is necessary to execute transactions -> as a Letter of Credit should be.