import pandas as pd
import random
from faker import Faker
from datetime import timedelta

# Initialize Faker
fake = Faker()
Faker.seed(42)
random.seed(42)

NUM_CANDIDATES = 50
NUM_APPLICATIONS = 60
NUM_INTERVIEWS = 80

def generate_dirty_data():
    # ---------------------------------------------------------
    # 1. GENERATE RAW_CANDIDATES
    # ---------------------------------------------------------
    candidates = []
    sources = ['LinkedIn', 'Referral', 'Career Page']
    dirty_sources = ['LinkdIn', 'referral', 'Career  Page', 'Job Board']
    
    for i in range(1, NUM_CANDIDATES + 1):
        c_id = f"C{i:03d}"
        name = fake.name()
        src = random.choice(sources)
        dt = fake.date_between(start_date='-2y', end_date='today')
        
        # --- Injecting Dirty Data ---
        if i == 5: name = None  # Missing name
        if i == 10: src = random.choice(dirty_sources)  # Domain typo
        if i == 15: dt = dt.strftime("%m/%d/%Y")  # Bad date format
        if i == 20: dt = fake.date_between(start_date='+1y', end_date='+5y')  # Future date
        if i == 25: name = name + "   "  # Whitespace padding
        if i == 30: c_id = None  # Null Primary Key
        
        candidates.append([c_id, name, src, str(dt)])
        
        # Inject exact duplicate
        if i == 3: 
            candidates.append([c_id, name, src, str(dt)])

    df_candidates = pd.DataFrame(candidates, columns=['candidate_id', 'full_name', 'source', 'profile_created_date'])

    # ---------------------------------------------------------
    # 2. GENERATE RAW_APPLICATIONS
    # ---------------------------------------------------------
    applications = []
    roles = ['Junior', 'Senior', 'Executive']
    
    for i in range(1, NUM_APPLICATIONS + 1):
        app_id = f"A{i:03d}"
        c_id = f"C{random.randint(1, NUM_CANDIDATES):03d}"
        role = random.choice(roles)
        applied = fake.date_between(start_date='-1y', end_date='today')
        
        # Decision date is normally after applied
        if random.random() > 0.4:
            decision = applied + timedelta(days=random.randint(5, 60))
        else:
            decision = None
            
        salary = random.randint(50000, 200000)
        
# --- Injecting Dirty Data ---
        if i == 7: c_id = "C999"  # Orphan candidate (Referential Integrity)
        if i == 12: decision = applied - timedelta(days=10)  # Logic error: decision before applied
        if i == 17: role = "Mid-Level"  # Invalid domain
        if i == 22: salary = f"{salary//1000}k"  # Type inconsistency (String)
        if i == 27: salary = -50000  # Invalid numeric (Negative)
        if i == 32: salary = f"${salary:,}"  # Type inconsistency (Currency formatting)
        if i == 37: applied = applied.strftime("%d-%m-%Y")  # Bad date format (applied)
        if i == 42: salary = None  # Missing salary
        
        if i == 45: applied = None  # Missing mandatory date (Null applied_date)
        if i == 48: 
            # Bad date format with slashes (decision)
            if decision:
                decision = decision.strftime("%m/%d/%Y") 
            else:
                decision = "12/31/2023" # Force a bad format if it happened to be None
        if i == 52: applied = "TBD"  # String text inside a date column
        if i == 55: decision = "Pending"  # String text inside a date column
        if i == 58: applied = applied + timedelta(days=365*50)  # Future applied date (Impossible)

        applied_val = str(applied) if applied is not None else None
        decision_val = str(decision) if decision is not None else None

        applications.append([app_id, c_id, role, applied_val, decision_val, salary])


    df_applications = pd.DataFrame(applications, columns=['app_id', 'candidate_id', 'role_level', 'applied_date', 'decision_date', 'expected_salary'])

    # ---------------------------------------------------------
    # 3. GENERATE RAW_INTERVIEWS
    # ---------------------------------------------------------
    interviews = []
    outcomes = ['Passed', 'Rejected', 'No Show']
    
    for i in range(1, NUM_INTERVIEWS + 1):
        int_id = f"I{i:03d}"
        app_id = f"A{random.randint(1, NUM_APPLICATIONS):03d}"
        int_date = fake.date_between(start_date='-1y', end_date='today')
        outcome = random.choice(outcomes)
        
        # --- Injecting Dirty Data ---
        if i == 8: app_id = "A999"  # Orphan application
        if i == 16: int_date = fake.date_between(start_date='+1m', end_date='+1y')  # Future interview date
        if i == 24: outcome = "pass"  # Wrong casing
        if i == 32: outcome = "Rescheduled"  # Invalid domain
        if i == 40: 
            outcome = "Rejected"
            int_date = None  # Missing date but has outcome
        if i == 48: 
            if int_date:
                int_date = int_date.strftime("%Y/%m/%d")  # Bad date format
                
        interviews.append([int_id, app_id, str(int_date) if int_date else None, outcome])

    df_interviews = pd.DataFrame(interviews, columns=['interview_id', 'app_id', 'interview_date', 'outcome'])

    return df_candidates, df_applications, df_interviews

# Generate the data
df_candidates, df_applications, df_interviews = generate_dirty_data()

# Save to CSV
df_candidates.to_csv('..\\source_ats\\raw_candidates.csv', index=False)
df_applications.to_csv('..\\source_ats\\raw_applications.csv', index=False)
df_interviews.to_csv('..\\source_ats\\raw_interviews.csv', index=False)

print("Successfully generated datasets")