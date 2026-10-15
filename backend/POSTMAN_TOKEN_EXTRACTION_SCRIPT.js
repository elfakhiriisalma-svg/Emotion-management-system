/**
 * Postman Test Script - Extract JWT Token from Login Response
 * 
 * This script automatically extracts the JWT token from the login response
 * and stores it in an environment variable called "TOKEN"
 * 
 * Usage:
 * 1. Add this script to the "Tests" tab of your Login request
 * 2. Send the request
 * 3. The token will be automatically stored in the TOKEN environment variable
 * 4. Use {{TOKEN}} in other requests' Authorization headers
 */

// ==================== MAIN SCRIPT ====================

// Test 1: Verify response status is 200
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Extract and store JWT token
if (pm.response.code === 200) {
    try {
        var jsonData = pm.response.json();
        
        // Verify token exists in response
        if (jsonData.token) {
            // Store token in TOKEN environment variable
            pm.environment.set("TOKEN", jsonData.token);
            
            // Optional: Store other useful information
            if (jsonData.id) {
                pm.environment.set("userId", jsonData.id);
            }
            if (jsonData.email) {
                pm.environment.set("userEmail", jsonData.email);
            }
            if (jsonData.role) {
                pm.environment.set("userRole", jsonData.role);
            }
            if (jsonData.fullName) {
                pm.environment.set("userFullName", jsonData.fullName);
            }
            
            // Log success message
            console.log("✅ Token JWT extrait et stocké avec succès");
            console.log("Token (preview): " + jsonData.token.substring(0, 20) + "...");
            console.log("User ID: " + jsonData.id);
            console.log("User Role: " + jsonData.role);
            
            // Test: Verify token was stored
            pm.test("Token stored in environment", function () {
                pm.expect(pm.environment.get("TOKEN")).to.not.be.empty;
            });
        } else {
            console.error("❌ Token non trouvé dans la réponse");
            pm.test("Token exists in response", function () {
                pm.expect(jsonData.token).to.exist;
            });
        }
    } catch (error) {
        console.error("❌ Erreur lors de l'extraction du token:", error);
        throw error;
    }
} else {
    console.error("❌ La requête a échoué avec le code:", pm.response.code);
    try {
        var errorBody = pm.response.json();
        console.error("Message d'erreur:", errorBody);
    } catch (e) {
        console.error("Erreur lors de la lecture du body:", e);
    }
}

// ==================== ALTERNATIVE VERSIONS ====================

/**
 * VERSION SIMPLIFIÉE (Minimal)
 * 
 * if (pm.response.code === 200) {
 *     var jsonData = pm.response.json();
 *     pm.environment.set("TOKEN", jsonData.token);
 * }
 */

/**
 * VERSION AVEC GESTION D'ERREURS AVANCÉE
 * 
 * pm.test("Login successful", function () {
 *     pm.response.to.have.status(200);
 *     pm.expect(pm.response.json()).to.have.property('token');
 * });
 * 
 * var responseJson = pm.response.json();
 * 
 * if (responseJson && responseJson.token) {
 *     pm.environment.set("TOKEN", responseJson.token);
 *     
 *     if (responseJson.id) pm.environment.set("userId", responseJson.id);
 *     if (responseJson.email) pm.environment.set("userEmail", responseJson.email);
 *     if (responseJson.role) pm.environment.set("userRole", responseJson.role);
 *     if (responseJson.fullName) pm.environment.set("userFullName", responseJson.fullName);
 *     
 *     console.log("Token stored successfully");
 *     console.log("User ID:", responseJson.id);
 *     console.log("User Role:", responseJson.role);
 * } else {
 *     console.error("Token not found in response");
 *     pm.test("Token extraction failed", function () {
 *         pm.expect(responseJson.token).to.exist;
 *     });
 * }
 */

