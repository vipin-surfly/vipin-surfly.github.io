// Locate the meta tag
var viewportMeta = document.querySelector('meta[name="viewport"]');
if (viewportMeta) {
  // Update the content attribute to disable pinch-to-zoom
  viewportMeta.setAttribute('content', 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no');
} else {
  // If the meta tag doesn't exist, create and append it
  viewportMeta = document.createElement('meta');
  viewportMeta.name = 'viewport';
  viewportMeta.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';
  document.head.appendChild(viewportMeta);
}
