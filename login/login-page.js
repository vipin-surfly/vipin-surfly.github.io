const loginForm = document.getElementById("login-form");
const loginButton = document.getElementById("login-form-submit");
const loginErrorMsg = document.getElementById("login-error-msg");

loginButton.addEventListener("click", (e) => {
    e.preventDefault();
    const username = loginForm.username.value;
    const password = loginForm.password.value;

    if (username === "vipin" && password === "vipin") {
        alert("You have successfully logged in.");
        document.cookie = "username=vipin"; 
        //location.reload();
        location.replace("main.html")
    } else {
        loginErrorMsg.style.opacity = 1;
    }
})
