1) Avoid re-entrancy by using send() instead of call()
2) Avoid timestamp dependance and transaction ordering by using manual input to end auctions rather than time-based.
3) Integer underflow is mitigated by the front-end input validation. Integer overflow and underflow are mitigated by preventing users from directly setting the value of transfer --> in all situations the amount is set in the Bill of Exchange first, then others can choose to execute the transaction with that amount. 
4) Similarly, DoS is mitigated as there is no payout to lower bidders, hence preventing DoS
5) tx.origin is never used to prevent phishing attacks