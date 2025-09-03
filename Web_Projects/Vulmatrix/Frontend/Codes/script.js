document.addEventListener('DOMContentLoaded', function() {
    const hamburgerBtn = document.getElementById('Menu');
    const closeBtn = document.getElementById('closeBtn');
    const sideMenu = document.getElementById('sideMenu');
    const overlay = document.getElementById('overlay');
    const body = document.body;

//elementos do sistema de login
const userIcon = document.getElementById('userIcon'); //criação da constante icone do usuário
const userStatus = document.getElementById('userStatus'); //criação da constante status
const loginModal = document.getElementById('loginModal'); //criação da constante modal de login
const closeLoginModal = document.getElementById('closeLoginModal'); //criação da constante botão de fechar modal de login
const loginForm = document.getElementById('loginForm'); //criação da constante formulário de login
const userDropdown = document.getElementById('userDropdown'); //criação da constante dropdown de usuário
const logoutBtn = document.getElementById('logoutBtn'); //criação da constante botão de logout
const contentLoginBtn = document.getElementById('contentLoginBtn'); //criação da constante botão de login no conteúdo

//estado de login (temporário por ser substituido pela lógica do Django mais pra frente)
let isLoggedIn = false; //variável para verificar se o usuário está logado ou não


//função para abrir o menu
function openMenu() {
    sideMenu.classList.add('active');
    overlay.classList.add('active');
    body.classList.add('menu-open');
    hamburgerBtn.classList.add('open');
}

//função para fechar o menu
function closeMenu() {
    sideMenu.classList.remove('active');
    overlay.classList.remove('active');
    body.classList.remove('menu-open');
    hamburgerBtn.classList.remove('open');
}

//função para abrir o modal de login
function openLoginModal() {
    loginModal.style.display = 'block'; // Mostra o modal de login
    overlay.classList.add('active'); // Adiciona a classe de overlay
    body.classList.add('modal-open'); // Adiciona a classe para evitar scroll
}

//função para fechar o modal de login
function closeLoginModalFunc() {
    loginModal.style.display = 'none'; // Esconde o modal de login
    overlay.classList.remove('active'); // Remove a classe de overlay
    body.classList.remove('modal-open'); // Remove a classe para evitar scroll
}

//função para o fazer o login (será alterada para Djano futuramente)
function login() {
    isLoggedIn = true; // Simula o login
    userStatus.textContent = 'Minha Conta'; // Atualiza o status do usuário
    userIcon.innerHTML = '<i class="fas fa-user-circle"></i> <span id="userStatus">Minha Conta</span>'; // Atualiza o ícone do usuário
    closeLoginModalFunc(); // Fecha o modal de login

    //onde será feita a requisição para backend Django
    //console.log('Usuário logado com sucesso!');
}

//Função para realizar logout
function logout() {
    isLoggedIn = false;
    userStatus.textContent = 'Entrar'; // Atualiza o status do usuário
    userIcon.innerHTML = '<i class="fas fa-user-circle"></i> <span id="userStatus">Entrar</span>'; // Atualiza o ícone do usuário
    userDropdown.style.display = 'none'; // Esconde o dropdown de usuário  

    //onde será feito a requisição backend Djano
    //console.log('Usuário deslogado com sucesso!');
}

//event listeners para o menu lateral
hamburgerBtn.addEventListener('click', openMenu);
closeBtn.addEventListener('click', closeMenu);
overlay.addEventListener('click', closeMenu);

//event listeners para o sistema de login
userIcon.addEventListener('click', function() {
    if (isLoggedIn) {
        // Se o usuário estiver logado, abrir o dropdown
        userDropdown.classList.toggle('active');
    } else {
        // Se o usuário não estiver logado, abrir o modal de login
        openLoginModal();
    }
});
   
closeLoginModal.addEventListener('click', closeLoginModalFunc);
    
loginForm.addEventListener('submit', function(e) {
    e.preventDefault();
    // Aqui você validaria as credenciais com o Django
    login();
});

logoutBtn.addEventListener('click', function(e) {
    e.preventDefault();
    logout();
});

//fechar o menu se pressionar com o mouse fora dele
document.addEventListener('click', function(e){
    if (isLoggedIn && !userIcon.contains(e.target) && !userDropdown.contains(e.target)) {
        userDropdown.classList.remove('active');
    }
});

//fechar o menu ao pressionar a tecla ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});
});