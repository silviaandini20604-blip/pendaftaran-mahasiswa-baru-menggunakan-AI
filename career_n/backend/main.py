from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_mysqldb import MySQL
import joblib
import numpy as np
import os
from datetime import datetime

# Inisialisasi Flask app
app = Flask(__name__)
CORS(app)  # Biar bisa terima request dari frontend

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''  
app.config['MYSQL_DB'] = 'career_n'
mysql = MySQL(app)
# Variabel buat nyimpen direktori file
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Variabel buat nyimpen model AI
ocean_model = None
career_model = None  
aptitude_model = None
aptitude_encoder = None

# Pesan motivasi buat yang gagal tes
MOTIVATIONAL_MESSAGES = [
    "Jangan menyerah! Setiap kegagalan adalah batu loncatan menuju kesuksesan. ✨",
    "Percayalah pada prosesnya. Waktumu akan datang dengan lebih baik! 🚀",
    "Kegagalan hari ini adalah persiapan untuk kesuksesan besok. Tetap semangat! 💪",
    "Setiap ahli pernah menjadi pemula. Teruslah berusaha dan belajar! 📚",
    "Journey mu belum berakhir di sini. Buka bab baru dan raih mimpimu! 🌟"
]

def load_models():
    """Load semua model machine learning yang dibutuhkan"""
    global ocean_model, career_model, aptitude_model, aptitude_encoder
    
    try:
        # Load model OCEAN buat analisis kepribadian
        ocean_model = joblib.load(os.path.join(BASE_DIR, 'models', 'ocean_model.pkl'))        
        # Load model career buat rekomendasi karir
        career_model = joblib.load(os.path.join(BASE_DIR, 'models', 'career_model.pkl'))        
        # Load model aptitude buat tes kemampuan
        aptitude_pack = joblib.load(os.path.join(BASE_DIR, 'models', 'aptitude_model.pkl'))
        aptitude_model = aptitude_pack["model"]
        aptitude_encoder = aptitude_pack["encoder"]
        
        print("✅ Semua model AI berhasil diload!")
        
    except Exception as e:
        print("❌ Error loading models:", e)

load_models()
# =========================================================
# RUTE LOGIN
@app.route('/api/login', methods=['POST'])
def login():
    """Handle login user"""
    data = request.json
    username = data.get('username')
    password = data.get('password')
    
    # Cek credentials di database
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM users WHERE username = %s AND password = %s", (username, password))
    user = cur.fetchone()
    cur.close()
    
    if user:
        # Kalo login berhasil, return data user
        return jsonify({
            'message': 'Login successful',
            'user': {
                'id': user[0],
                'username': user[1],
                'email': user[3],
                'full_name': user[4]
            }
        }), 200
    else:
        # Kalo gagal, return error
        return jsonify({'error': 'Invalid credentials'}), 401
# =========================================================
# RUTE PEMILIHAN JURUSAN
@app.route('/api/majors', methods=['GET'])
def get_majors():
    """Ambil data jurusan berdasarkan kategori (UNIVERSITY/SMK)"""
    category = request.args.get('category', 'UNIVERSITY')
    
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM majors WHERE category = %s", (category,))
    majors = cur.fetchall()
    cur.close()
    
    # Format data jurusan buat response
    majors_list = []
    for major in majors:
        majors_list.append({
            'id': major[0],
            'name': major[1],
            'category': major[2],
            'description': major[3]
        })
    
    return jsonify(majors_list), 200

# =========================================================
# RUTE TES KEPRIBADIAN OCEAN
@app.route('/api/analyze-ocean', methods=['POST'])
def analyze_ocean():
    """Analisis hasil tes kepribadian OCEAN"""
    try:
        data = request.json

        # Cek model udah ke-load apa belum
        if ocean_model is None:
            print("❌ OCEAN model is None")
            return jsonify({"error": "Model OCEAN not loaded"}), 500

        # Proses jawaban user
        answers = np.array(data['answers'])
        ocean_score = np.mean(answers).reshape(1, -1)  # Convert ke format yang dimodel mau
        prediction = ocean_model.predict(ocean_score)[0]

        return jsonify({
            'personality_type': int(prediction),
            'scores': float(prediction)
        }), 200

    except Exception as e:
        print("❌ Error in /api/analyze-ocean:", e)
        return jsonify({'error': str(e)}), 500
# =========================================================
# RUTE TES APTITUDE
@app.route('/api/submit-aptitude', methods=['POST'])
def submit_aptitude():
    """Proses hasil tes aptitude dan hitung score"""
    try:
        if aptitude_model is None:
            print("❌ Aptitude model is None")
            return jsonify({"error": "Aptitude model not loaded"}), 500

        data = request.json
        user_answers = data['answers']
        correct_answers = data['correct_answers']

        # Validasi: semua soal harus dijawab
        if any(a is None or a == "" for a in user_answers):
            return jsonify({"error": "All questions must be answered"}), 400

        # Hitung score berdasarkan jawaban yang bener
        score = sum(1 for ua, ca in zip(user_answers, correct_answers) if ua == ca)
        total_questions = len(correct_answers)
        percentage = (score / total_questions) * 100

        # Tentukan lulus/tidak (passing score 70%)
        passing_score = 70
        passed = percentage >= passing_score

        return jsonify({
            "score": score,
            "total_questions": total_questions,
            "percentage": percentage,
            "passed": passed,
            "passing_score": passing_score
        }), 200

    except Exception as e:
        print("❌ Error in /api/submit-aptitude:", e)
        return jsonify({'error': str(e)}), 500
# =========================================================
# RUTE REKOMENDASI KARIR
@app.route('/api/recommend-career', methods=['POST'])
def recommend_career():
    """Kasih rekomendasi karir berdasarkan hasil OCEAN + Aptitude"""
    try:
        data = request.json
        ocean_scores = data['ocean_scores']
        aptitude_score = data['aptitude_score']
        
        # Siapin data buat diprediksi model
        features = np.array([[
            ocean_scores['openness'],
            ocean_scores['conscientiousness'], 
            ocean_scores['extraversion'],
            ocean_scores['agreeableness'],
            ocean_scores['neuroticism'],
            aptitude_score
        ]])
        
        # Dapetin rekomendasi karir dari model AI
        prediction = career_model.predict(features)[0]
        recommended_career = int(prediction)
        
        # Cari major ID yang sesuai dengan rekomendasi karir
        cur = mysql.connection.cursor()
        cur.execute("SELECT id FROM majors WHERE name LIKE %s", (f"%{recommended_career}%",))
        major = cur.fetchone()
        cur.close()
        
        major_id = major[0] if major else None
        
        return jsonify({
            'recommended_career': recommended_career,
            'recommended_major_id': major_id
        }), 200
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
# =========================================================
# RUTE SIMPAN HASIL TES
@app.route('/api/save-test-result', methods=['POST'])
def save_test_result():
    """Simpan semua hasil tes ke database"""
    data = request.json
    user_id = data['user_id']
    ocean_scores = data['ocean_scores']
    aptitude_score = data['aptitude_score']
    passed = data['passed']
    recommended_major_id = data.get('recommended_major_id')
    chosen_major_id = data.get('chosen_major_id')
    
    cur = mysql.connection.cursor()
    try:
        # Insert semua data hasil tes ke database
        cur.execute("""
            INSERT INTO test_results 
            (user_id, ocean_score_openness, ocean_score_conscientiousness, ocean_score_extraversion, 
             ocean_score_agreeableness, ocean_score_neuroticism, aptitude_score, passed, 
             recommended_major_id, chosen_major_id) 
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            user_id, ocean_scores['openness'], ocean_scores['conscientiousness'],
            ocean_scores['extraversion'], ocean_scores['agreeableness'], 
            ocean_scores['neuroticism'], aptitude_score, passed,
            recommended_major_id, chosen_major_id
        ))
        mysql.connection.commit()
        
        # Kasih pesan motivasi kalo gagal tes
        message = None
        if not passed:
            import random
            message = random.choice(MOTIVATIONAL_MESSAGES)
        
        return jsonify({
            'message': 'Test result saved successfully',
            'motivational_message': message
        }), 201
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cur.close()
@app.route('/ping', methods=['GET'])
def ping():
    return jsonify({"status": "ok", "message": "Backend is running"}), 200

# =========================================================
if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True, port=5000)
    # app.run(debug=True, port=5000)