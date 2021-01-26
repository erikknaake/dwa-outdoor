const updateAuthenticationElements = () => {
    const token = localStorage.getItem("token");
    const role = localStorage.getItem("role");
    const isAdmin = localStorage.getItem("isAdmin") === "true";

    const isAuthenticated = !!token;

    document.querySelectorAll('[data-show-if-authenticated]').forEach(elem => {
        elem.classList.toggle('hidden', !isAuthenticated);
    })

    document.querySelectorAll('[data-show-if-guest]').forEach(elem => {
        elem.classList.toggle('hidden', isAuthenticated);
    })

    document.querySelectorAll('[data-show-if-role]').forEach(elem => {
        const requiredRoles = elem.dataset.showIfRole.split(',').map(r => r.trim());
        const shouldShowElem = (requiredRoles.includes("Admin") && isAdmin) || requiredRoles.includes(role);

        elem.classList.toggle('hidden', !shouldShowElem);
    })
}

window.topics.on('authStateChanged', () => updateAuthenticationElements())
updateAuthenticationElements();