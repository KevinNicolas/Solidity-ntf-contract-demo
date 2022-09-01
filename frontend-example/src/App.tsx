import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useEffect, useState } from "react";
import { useAccount, useSigner } from "wagmi";
import "./App.css";

import { abi } from "./assets/DemoNft.json";
import {
  NftContractController,
  TokenInfo,
} from "./helpers/Ntf-contract-controller";

function App() {
  const contractAddress = "0x748fEED8f60b3340a4f6B2C21d00AbA36DC438b6";

  const [nftController] = useState(new NftContractController());
  const [selectedTokenSymbol, setSelectedTokenSymbol] = useState("FOX");
  const [tokenInfo, setTokenInfo] = useState<TokenInfo | null>(null);

  const account = useAccount();
  const { data: signer } = useSigner();

  useEffect(() => {
    if (signer) nftController.init(contractAddress, abi, signer);
  }, [signer]);

  const handleGetTokenInfo = async () => {
    const info = await nftController.getTokenInfo(selectedTokenSymbol as any);
    console.info(info);
    setTokenInfo(info);
  };

  return (
    <div>
      {tokenInfo ? (
        <div>
          <img src={`http://localhost:3010/${tokenInfo.imageUrl}`} alt="" />
          <br />
          <span>
            {tokenInfo.name} - [ {tokenInfo.symbol} ] ({" "}
            {tokenInfo.priceInEthers} ETH )
          </span>
        </div>
      ) : (
        <></>
      )}
      <br />
      <ConnectButton />
      <div className="get-nft-info-container">
        <select
          onChange={(event) => setSelectedTokenSymbol(event.target.value)}
          name="nfts"
          id="nfts"
        >
          <option value="FOX">FOX</option>
          <option value="KIN">KIN</option>
          <option value="JAI">JAI</option>
        </select>
        <button onClick={handleGetTokenInfo}>Get token info</button>
      </div>
    </div>
  );
}

export default App;
