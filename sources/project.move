module MyModule::StudentIdentity {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;

    /// Struct representing a student's decentralized identity
    struct StudentID has store, key {
        student_name: String,           // Student's full name
        student_email: String,          // Student's email address
        institution: String,            // Educational institution
        authorized_apps: vector<String>, // List of apps student is registered with
        is_verified: bool,              // Verification status
    }

    /// Error codes
    const E_STUDENT_NOT_REGISTERED: u64 = 1;
    const E_STUDENT_ALREADY_REGISTERED: u64 = 2;

    /// Function to register a new student identity
    public fun register_student(
        student: &signer, 
        name: String, 
        email: String, 
        institution: String
    ) {
        let student_addr = signer::address_of(student);
        
        // Ensure student hasn't already registered
        assert!(!exists<StudentID>(student_addr), E_STUDENT_ALREADY_REGISTERED);
        
        let student_identity = StudentID {
            student_name: name,
            student_email: email,
            institution,
            authorized_apps: vector::empty<String>(),
            is_verified: false,
        };
        
        move_to(student, student_identity);
    }

    /// Function for students to authenticate and login to applications
    public fun authenticate_for_app(
        student: &signer, 
        app_name: String
    ) acquires StudentID {
        let student_addr = signer::address_of(student);
        
        // Ensure student is registered
        assert!(exists<StudentID>(student_addr), E_STUDENT_NOT_REGISTERED);
        
        let student_identity = borrow_global_mut<StudentID>(student_addr);
        
        // Add app to authorized apps list if not already present
        if (!vector::contains(&student_identity.authorized_apps, &app_name)) {
            vector::push_back(&mut student_identity.authorized_apps, app_name);
        };
        
        // Mark as verified after first app authentication
        student_identity.is_verified = true;
    }
}