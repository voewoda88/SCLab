const validation = (type, value) => {
    switch(type) {
        case 'email': return /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/.test(value);
        case 'text': return /^[a-zA-Z ]+$/.test(value);
        case 'phone': return /^(\+375)?\(?(29|33|44)\)?\d{3}-?\d{2}-?\d{2}$/.test(value);
        default: return true;
    }
}

const formHandle = () => {
    const inputs = Array.from(document.querySelectorAll('.input'));
    const labels = Array.from(document.querySelectorAll('.input-label'));
    const form = document.querySelector('.request-form');
    const submitBtn = document.querySelector('#submit-btn');
    const phoneInput = document.getElementById('phone');
    const productSelect = document.getElementById('00NIR000009lGZF');

    inputs.forEach((input, index) => {
        input.addEventListener('focus', () => {
            labels[index].classList.add('active');
            inputs[index].classList.add('active');
        })
        input.addEventListener('blur', () => {
            if(!input.value) {
                labels[index].classList.remove('active');
                inputs[index].classList.remove('active');
            } 
        })
        input.addEventListener("click", () => {
            input.classList.remove('error');
        })
    })

    submitBtn.addEventListener('click', (e) => {
        e.preventDefault();

        inputs.forEach((input, index) => {
            if(!validation(input.getAttribute('data-custom-type'), input.value)) {
                input.classList.add('error');
            }
        })

        console.log(productSelect.value);
        
        if(!inputs.find(input => input.classList.contains('error')) && productSelect.value) {
            form.submit();
        }
    })

    phoneInput.addEventListener('input', () => {
        let phoneNumber = phoneInput.value.replace(/\D/g, ''); // Удалить все нецифровые символы
        let formattedNumber = '+375';

        if (phoneNumber.startsWith('375')) {
            formattedNumber = '+375';
            phoneNumber = phoneNumber.slice(3); // Удалить код страны
        }

        if (phoneNumber.length > 0) {
            formattedNumber += '(' + phoneNumber.substring(0, 2);
        }

        if (phoneNumber.length > 2) {
            formattedNumber += ')' + phoneNumber.substring(2, 5);
        }

        if (phoneNumber.length > 5) {
            formattedNumber += '-' + phoneNumber.substring(5, 7);
        }
        
        if (phoneNumber.length > 7) {
            formattedNumber += '-' + phoneNumber.substring(7, 9);
        }
    
        phoneInput.value = formattedNumber;
    })

    phoneInput.addEventListener('keydown', (event) => {
        if (event.key === 'Backspace') {
            if(phoneInput.value === '+375') {
                phoneInput.value = '';
            }
        }
    });
}


document.addEventListener('DOMContentLoaded', formHandle);