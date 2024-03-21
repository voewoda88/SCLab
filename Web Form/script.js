const formHandle = () => {
    const inputs = Array.from(document.querySelectorAll('.input'));
    const labels = Array.from(document.querySelectorAll('.input-label'));
    const form = document.querySelector('.request-form');
    const submitBtn = document.querySelector('#submit-btn');

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
        
        if(!inputs.find(input => input.classList.contains('error'))) form.submit();
    })
}


document.addEventListener('DOMContentLoaded', formHandle);