window.addEventListener('DOMContentLoaded', (event) => {
  // Create a button element
  const button = document.createElement('button');

  // Set button text
  button.textContent = 'Click Me';

  // Add event listener to the button
  button.addEventListener('click', () => {
    alert('Button clicked!');
  });

  // Append the button to the body of the document
  document.body.appendChild(button);
});
