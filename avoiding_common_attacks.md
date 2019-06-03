## Thought Processes for Common Attacks

- there is an upper limit to the number of participants, defined by the constant MAX_PARTICIPANTS 

 there are loops which iterate through the participants array / map, and without a limit we would be exposed to block gas limits

- there is an upper limit on the contribution amount, which together with the constraint on the number of participants, will serve to limit the total amount of value held in the contract

- in the base contract, decided to always revert on a call to the fallback function. this was really to control the way funds come into the contract, and for usage to be always via well defined function. In my view, this decreases attack vector and unpredictable behavior

= 
