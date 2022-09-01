import { ethers, ContractInterface } from "ethers";

export type TokenSymbols = "FOX" | "KIN" | "JAI" | "WIN";

export interface TokenInfo {
  name: string;
  symbol: string;
  imageUrl: string;
  priceInEthers: number;
  availableQuantity: number;
}

export interface NftTokenInfo {
  id: number;
  owner: string;
  tokenSymbol: string;
}

export class NftContractController {
  contract: ethers.Contract | null = null;

  async init(
    contractAddress: string,
    abi: ContractInterface,
    signer: ethers.Signer
  ): Promise<void> {
    this.contract = await new ethers.Contract(
      contractAddress,
      abi,
      signer
    ).deployed();
  }

  #parseHexToEthers = (price: string) => parseInt(price, 16) / 10 ** 18;

  // Actions
  async buyToken(account: string, tokenSymbol: TokenSymbols): Promise<any> {
    const { priceInEthers } = await this.getTokenInfo(tokenSymbol);

    const response = await this.contract?.buyToken(account, tokenSymbol, {
      value: ethers.utils.parseEther(priceInEthers.toString()),
    });

    return response;
  }

  async obtainToken(account: string, tokenSymbol: TokenSymbols): Promise<any> {
    const response = await this.contract?.mint(account, tokenSymbol);
    return response;
  }

  async tryObtainWinnerToken(account: string): Promise<any> {
    const response = await this.contract?.obtainWinnerToken(account);
    return response;
  }

  // Getters
  async getAllTokens(): Promise<NftTokenInfo[]> {
    const allTokens: any[] = await this.contract?.getAllTokens();

    return allTokens.map((token) => ({
      id: this.#parseHexToEthers(token.id._hex),
      owner: token.owner,
      tokenSymbol: token.tokenSymbol,
    }));
  }

  async getAllTokensOfAccount(account: string): Promise<NftTokenInfo[]> {
    const tokens: any[] = await this.contract?.getAllTokensOf(account);

    return tokens.map((token) => ({
      id: this.#parseHexToEthers(token.id._hex),
      owner: token.owner,
      tokenSymbol: token.tokenSymbol,
    }));
  }

  async getTokenInfo(tokenName: TokenSymbols): Promise<TokenInfo> {
    const rawTokenInfo: any = await this.contract?.getTokensInfo(tokenName);

    return {
      availableQuantity: rawTokenInfo.availableQuantity,
      imageUrl: rawTokenInfo.imageUrl,
      name: rawTokenInfo.name,
      priceInEthers: this.#parseHexToEthers(rawTokenInfo.priceInEthers._hex),
      symbol: rawTokenInfo.symbol,
    };
  }

  async getWinner(): Promise<string | null> {
    const winner = await this.contract?.getWinner();
    return parseInt(winner) > 0 ? winner : null;
  }
}
