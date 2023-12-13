## Principle that MUST follow

#### https://docs.ethscriptions.com/esips/accepted-esips

## analyze pols

PolsMarket.sol: https://polygonscan.com/address/0x6aced66903866ffde0d85aab947c81c3f6c38cdd#readProxyContract

PRC20Ethscriptions.sol: https://polygonscan.com/address/0xfd94c258927bd4098fe4e3aac6e6a5fac6031ccf#code

PRC20SRelayer.sol: https://polygonscan.com/address/0x388a04a77a8048f787bef0fb74A33e5683C6046C#readProxyContract


work flow (mainly explain how to split using sc):

1. user sends tx to PRC20Ethscriptions with call data being concat(mint_tx1, mint_tx2, ...)
    eg, https://polygonscan.com/tx/0x4f0e5859b6d22ec22afa14c4b7475e8027853d0714d32b55157dcfa1fc5b4e74

2. user obtains relayer's sig

3. relayer or user invokes PRC20SRelayer.deposit(), PRC20Ethscriptions will mint tokens to user, event ethscriptions_protocol_DepositForEthscriptions will be emitted. (Guess: Old ethscriptionId should be invalid, and new txHash should be valid and new ethscriptionId with new amt value)
    eg, https://polygonscan.com/tx/0xba8781b5b8126f98faec2262188185666a482b8ea8b2ed1f3c0e7494ce970397

4. marketplace's trade won't touch PRC20Ethscriptions, only events, legal trade matching is performed in indexer.
