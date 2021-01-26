export function decorateHookWithTokens(Hooks) {
    Hooks.Token = {
        mounted() {
            this.handleEvent("token", ({token, role, is_admin}) => {
                localStorage.setItem("token", token);
                localStorage.setItem("isAdmin", is_admin);
                localStorage.setItem("role", role);

                window.topics.broadcast('authStateChanged');
            });
        }
    };

    Hooks.Authenticate = {
        mounted() {
            const token = localStorage.getItem("token");
            this.pushEvent("AuthenticateToken", {token});
        }
    };

    Hooks.Logout = {
        mounted() {
            this.pushEvent("Logout");

            this.handleEvent("loggedOut", () => {
                localStorage.removeItem("token");
                localStorage.removeItem("role");
                window.topics.broadcast('authStateChanged');
            });
        }
    };
}

