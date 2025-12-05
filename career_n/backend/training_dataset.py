import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score
import joblib
import os

class DatasetTrainer:
    def __init__(self):
        self.models_dir = 'models'
        os.makedirs(self.models_dir, exist_ok=True)

    def model_exists(self, filename):
        return os.path.exists(os.path.join(self.models_dir, filename))

    # ========================= OCEAN MODEL =========================
    def train_ocean_model(self):
        print("⏳ Training OCEAN model...")

        if self.model_exists("ocean_model.pkl"):
            print("✔ OCEAN model already trained. Skipping.")
            return True

        try:
            df = pd.read_csv('data/ocean_dataset/data-final.csv', sep="\t", engine="python")
            prefixes = ["EXT", "EST", "AGR", "CSN", "OPN"]
            ocean_scores = []

            for p in prefixes:
                cols = [c for c in df.columns if c.startswith(p)]

                # skip kalau gak ada kolom prefix
                if len(cols) == 0:
                    continue

                # convert ke angka
                df[cols] = df[cols].apply(pd.to_numeric, errors='coerce')

                # tambahkan rata-rata prefix itu
                ocean_scores.append(df[cols].mean(axis=1))

            # gabungkan 5 trait, lalu hitung rata-rata keseluruhan
            df["ocean_score"] = np.mean(ocean_scores, axis=0)

            # HAPUS BARIS YANG OCEAN-SCORE ADA NaN
            df = df.dropna(subset=["ocean_score"])

            # Feature hanya ocean_score
            X = df[['ocean_score']]
            y = pd.qcut(df['ocean_score'], 5, labels=False)  # kategori 5 kelas

            model = RandomForestClassifier(n_estimators=100, random_state=42)
            model.fit(X, y)

            joblib.dump(model, f"{self.models_dir}/ocean_model.pkl")

            print("✔ OCEAN model saved!")
            return True

        except Exception as e:
            print(f"❌ Error training OCEAN model: {e}")
            return False

    # ========================= CAREER MODEL =========================
    def train_career_model(self):
        print("⏳ Training career model...")

        if self.model_exists("career_model.pkl"):
            print("✔ Career model already trained. Skipping.")
            return True

        try:
            df = pd.read_csv('data/career_dataset/StudentsPerformance.csv')

            # Pastikan kolom pakai format benar
            df.rename(columns={
                'math score': 'math_score',
                'reading score': 'reading_score',
                'writing score': 'writing_score'
            }, inplace=True)

            # Tambahkan ocean_score dari mean 3 score (contoh integrasi)
            df['ocean_score'] = df[['math_score','reading_score','writing_score']].mean(axis=1)

            # Buat label career dummy
            df['career_field'] = pd.qcut(df['ocean_score'], 5, labels=False)

            X = df[['math_score', 'reading_score', 'writing_score', 'ocean_score']]
            y = df['career_field']

            model = RandomForestClassifier(n_estimators=100, random_state=42)
            model.fit(X, y)

            joblib.dump(model, f"{self.models_dir}/career_model.pkl")

            print("✔ Career model saved!")
            return True

        except Exception as e:
            print(f"❌ Error training career model: {e}")
            return False

    # ========================= APTITUDE MODEL =========================
    def train_aptitude_model(self):
        print("⏳ Training aptitude model (AI)...")

        if self.model_exists("aptitude_model.pkl"):
            print("✔ Aptitude model already trained. Skipping.")
            return True

        try:
            # Load EduQG dataset
            df = pd.read_csv("data/aptitude_questions/eduqg_llm_formatted.csv")

            # Generate difficulty automatically from prompt length
            df["prompt_length"] = df["prompt"].str.len()

            df["aptitude_level"] = pd.qcut(
                df["prompt_length"],
                3,
                labels=["Low", "Medium", "High"]
            )

            # Features
            X = df[["prompt_length"]]
            y = df["aptitude_level"]

            # Encode label
            encoder = LabelEncoder()
            y_encoded = encoder.fit_transform(y)

            # Split
            X_train, X_test, y_train, y_test = train_test_split(
                X, y_encoded, test_size=0.2, random_state=42
            )

            # Train model
            model = RandomForestClassifier(n_estimators=200, random_state=42)
            model.fit(X_train, y_train)

            # Akurasi
            preds = model.predict(X_test)
            acc = accuracy_score(y_test, preds)
            print(f"✔ Aptitude model trained. Accuracy: {acc*100:.2f}%")

            # Save model + encoder (NO passing score)
            aptitude_pack = {
                "model": model,
                "encoder": encoder
            }

            joblib.dump(aptitude_pack, f"{self.models_dir}/aptitude_model.pkl")

            print("✔ Aptitude model saved with ML!")
            return True

        except Exception as e:
            print(f"❌ Error training aptitude model: {e}")
            return False

    # ========================= TRAIN ALL =========================
    def train_all_models(self):
        print("========== TRAINING MODELS ==========")

        ocean_ok = self.train_ocean_model()
        career_ok = self.train_career_model()
        aptitude_ok = self.train_aptitude_model()

        print("=====================================")

        if all([ocean_ok, career_ok, aptitude_ok]):
            print("🎉 All models trained successfully!")
        else:
            print("⚠ Some models failed. Run again to continue training.")


if __name__ == "__main__":
    DatasetTrainer().train_all_models()