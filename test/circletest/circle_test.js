(function() {

var onLoad = function() {
    // Check for wasm support.
    if (!('WebAssembly' in window)) {
        alert('you need a browser with wasm support enabled :(');
    }

   Module.onRuntimeInitialized = function() {
    // Loads the module and uses it.
            window.Module = Module; // the exports of that instance
    };
}
    window.addEventListener('load', onLoad, true);
})();
