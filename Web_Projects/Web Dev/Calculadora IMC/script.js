function calcularIMC() {
    const altura = parseFloat(document.getElementById('altura').value);
    const peso = parseFloat(document.getElementById('peso').value);
    
    if (isNaN(altura) || isNaN(peso) || altura <= 0 || peso <= 0) {
        alert('Por favor, insira valores válidos para altura e peso.');
        return;
    }
    
    const imc = calcularValorIMC(peso, altura);
    const classificacao = classificarIMC(imc);
    
    mostrarResultado(imc, classificacao);
}

function calcularValorIMC(peso, altura) {
    return peso / (altura * altura);
}

function classificarIMC(imc) {
    if (imc < 18.5) return 'Abaixo do peso';
    if (imc < 25) return 'Peso normal';
    if (imc < 30) return 'Sobrepeso';
    if (imc < 35) return 'Obesidade grau I';
    if (imc < 40) return 'Obesidade grau II';
    return 'Obesidade grau III';
}

function mostrarResultado(imc, classificacao) {
    const resultadoDiv = document.getElementById('resultado');
    resultadoDiv.innerHTML = `
        <p>Atenção para sua classificação IMC: ${classificacao}</p>
        <p>Seu IMC: ${imc.toFixed(2)}</p>
    `;
    
    // Adicionar classes de acordo com a classificação
    resultadoDiv.className = 'resultado';
    if (classificacao.includes('Obesidade')) {
        resultadoDiv.classList.add('obesidade');
    } else if (classificacao.includes('Sobrepeso')) {
        resultadoDiv.classList.add('sobrepeso');
    } else if (classificacao.includes('Abaixo')) {
        resultadoDiv.classList.add('abaixo');
    } else {
        resultadoDiv.classList.add('normal');
    }
}