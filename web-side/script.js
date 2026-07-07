let currentData = null;

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.Action === 'Open') {
        currentData = data.Payload;
        document.getElementById('app').style.display = 'flex';
        updateUI(currentData);
        // Reset focus buttons UI to default active state
        document.querySelectorAll('.cam-focus-btn').forEach(btn => btn.classList.remove('active'));
        const defaultFocusBtn = document.querySelector('.cam-focus-btn[data-focus="torso"]');
        if (defaultFocusBtn) defaultFocusBtn.classList.add('active');
    }
});

function closeApp() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/Close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function refreshData() {
    fetch(`https://${GetParentResourceName()}/Refresh`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        if (data) {
            currentData = data;
            updateUI(data);
        }
    });
}

function updateUI(data) {
    if (!data) return;
    
    // Atualiza modelo
    document.getElementById('modelName').textContent = data.model || '-';
    
    // Atualiza grid de roupas
    const grid = document.getElementById('clothingGrid');
    grid.innerHTML = '';
    
    const clothingItems = [
        { key: 'hat', name: 'Chapéu' },
        { key: 'pants', name: 'Calça' },
        { key: 'arms', name: 'Braços' },
        { key: 'tshirt', name: 'Camisa' },
        { key: 'torso', name: 'Torso' },
        { key: 'vest', name: 'Colete' },
        { key: 'shoes', name: 'Sapatos' },
        { key: 'mask', name: 'Máscara' },
        { key: 'backpack', name: 'Mochila' },
        { key: 'glass', name: 'Óculos' },
        { key: 'ear', name: 'Brincos' },
        { key: 'watch', name: 'Relógio' },
        { key: 'bracelet', name: 'Pulseira' },
        { key: 'accessory', name: 'Acessório' },
        { key: 'decals', name: 'Decals' }
    ];
    
    clothingItems.forEach(item => {
        const clothing = data.clothing[item.key];
        if (clothing) {
            const div = document.createElement('div');
            div.className = 'clothing-item';
            div.innerHTML = `
                <h3>${item.name}</h3>
                <div class="value">Item: <span>${clothing.item}</span></div>
                <div class="value">Textura: <span>${clothing.texture}</span></div>
            `;
            grid.appendChild(div);
        }
    });
}

function copyToClipboard(text) {
    let textArea = document.createElement("textarea");
    textArea.value = text;
    textArea.style.position = "fixed";
    textArea.style.left = "-999999px";
    textArea.style.top = "-999999px";
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    
    let successful = false;
    try {
        successful = document.execCommand('copy');
    } catch (err) {
        console.error('Erro no fallback de copia:', err);
    }
    
    textArea.remove();
    
    if (successful) {
        return Promise.resolve();
    } else {
        return Promise.reject("Fallback copy failed");
    }
}

function copyFormatted(event) {
    if (!currentData) {
        console.error('Nenhum dado disponível para copiar');
        return;
    }
    
    const btn = event ? event.currentTarget : document.querySelector('.btn-success');
    const originalText = btn.innerHTML;
    
    btn.innerHTML = '⏳ Processando...';
    btn.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/Copy`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(currentData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Erro na resposta do servidor');
        }
        return response.json();
    })
    .then(result => {
        if (result === "Error") {
            throw new Error("Erro ao formatar os dados");
        }
        
        openModal("PRESET LUA GERADO", result);
        return copyToClipboard(result);
    })
    .then(() => {
        btn.innerHTML = '✓ Copiado!';
        btn.classList.add('btn-feedback-success');
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-success');
            btn.disabled = false;
        }, 2000);
    })
    .catch(error => {
        console.error('Erro ao copiar:', error);
        btn.innerHTML = '✗ Erro';
        btn.classList.add('btn-feedback-error');
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-error');
            btn.disabled = false;
        }, 2000);
    });
}

function copyJSON(event) {
    if (!currentData) {
        console.error('Nenhum dado disponível para copiar');
        return;
    }
    
    const btn = event ? event.currentTarget : document.querySelector('.btn-info');
    const originalText = btn.innerHTML;
    
    btn.innerHTML = '⏳ Processando...';
    btn.disabled = true;
    
    fetch(`https://${GetParentResourceName()}/CopyJSON`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(currentData)
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Erro na resposta do servidor');
        }
        return response.json();
    })
    .then(result => {
        if (result === "Error") {
            throw new Error("Erro ao gerar o JSON");
        }
        
        openModal("PRESET JSON GERADO", result);
        return copyToClipboard(result);
    })
    .then(() => {
        btn.innerHTML = '✓ Copiado!';
        btn.classList.add('btn-feedback-success');
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-success');
            btn.disabled = false;
        }, 2000);
    })
    .catch(error => {
        console.error('Erro ao copiar:', error);
        btn.innerHTML = '✗ Erro';
        btn.classList.add('btn-feedback-error');
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-error');
            btn.disabled = false;
        }, 2000);
    });
}

/* ==========================================================================
   CAMERA CONTROL FUNCTIONS
   ========================================================================== */
function rotatePlayer(direction) {
    const callbackName = direction === 'left' ? 'RotateLeft' : 'RotateRight';
    fetch(`https://${GetParentResourceName()}/${callbackName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function zoomCam(direction) {
    fetch(`https://${GetParentResourceName()}/Zoom`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(direction)
    });
}

function changeFocus(focusType) {
    // Update active state in HTML buttons
    document.querySelectorAll('.cam-focus-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.getAttribute('data-focus') === focusType) {
            btn.classList.add('active');
        }
    });

    fetch(`https://${GetParentResourceName()}/ChangeCameraFocus`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(focusType)
    });
}

/* ==========================================================================
   GENDER TOGGLE FUNCTION
   ========================================================================== */
function toggleGender() {
    const genderBtn = document.querySelector('.btn-gender-toggle');
    const originalContent = genderBtn.innerHTML;
    
    genderBtn.innerHTML = '<span class="gender-icon">⏳</span><span class="gender-label">Carregando...</span>';
    genderBtn.disabled = true;

    fetch(`https://${GetParentResourceName()}/ToggleGender`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    })
    .then(response => response.json())
    .then(data => {
        genderBtn.innerHTML = originalContent;
        genderBtn.disabled = false;
        if (data) {
            currentData = data;
            updateUI(data);
        }
    })
    .catch(err => {
        console.error('Erro ao alternar gênero:', err);
        genderBtn.innerHTML = originalContent;
        genderBtn.disabled = false;
    });
}

function GetParentResourceName() {
    let resourceName = 'M-Westy_ClothID';
    const scripts = document.getElementsByTagName('script');
    for (let i = 0; i < scripts.length; i++) {
        if (scripts[i].src) {
            const match = scripts[i].src.match(/\/([^\/]+)\/web-side/);
            if (match) {
                resourceName = match[1];
                break;
            }
        }
    }
    return resourceName;
}

/* ==========================================================================
   MODAL CONTROL LOGIC
   ========================================================================== */
let modalActiveText = "";

function openModal(title, text) {
    modalActiveText = text;
    document.getElementById('modalTitle').textContent = title;
    document.getElementById('modalText').textContent = text;
    document.getElementById('outputModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('outputModal').style.display = 'none';
    modalActiveText = "";
}

function copyModalText() {
    if (!modalActiveText) return;
    const btn = document.getElementById('modalCopyBtn');
    const originalText = btn.innerHTML;
    
    btn.innerHTML = '⏳ Processando...';
    btn.disabled = true;
    
    copyToClipboard(modalActiveText)
    .then(() => {
        btn.innerHTML = '✓ Copiado!';
        btn.classList.add('btn-feedback-success');
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-success');
            btn.disabled = false;
        }, 1500);
    })
    .catch(err => {
        btn.innerHTML = '✗ Erro';
        btn.classList.add('btn-feedback-error');
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.classList.remove('btn-feedback-error');
            btn.disabled = false;
        }, 1500);
    });
}

// Fecha com ESC
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        const modal = document.getElementById('outputModal');
        if (modal && modal.style.display === 'flex') {
            closeModal();
        } else {
            closeApp();
        }
    }
});

// Ofuscação dos créditos de autoria M-Westy no Front-End
document.addEventListener("DOMContentLoaded", function() {
    const cc = [68,101,115,101,110,118,111,108,118,105,100,111,32,112,111,114,32,77,45,87,101,115,116,121,32,169,32,50,48,50,54,46,32,84,111,100,111,115,32,111,115,32,100,105,114,101,105,116,111,115,32,114,101,115,101,114,118,97,100,111,115,46];
    const container = document.getElementById('creditsContainer');
    if (container) {
        container.textContent = String.fromCharCode(...cc);
    }
});
