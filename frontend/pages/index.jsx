import styles from "../styles/Home.module.css";
import AxelarComponent from "../components/AxelarComponent";
import MintNFTForm from "../components/mint";

export default function Home() {
  return (
    <div>
      <main className={styles.main}>
        <AxelarComponent></AxelarComponent>
      </main>
    </div>
  );
}
