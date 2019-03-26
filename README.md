# Blazor and WebAssembly

This repository contains samples for a presentation about using C# and .NET in the browser with Blazor.

## Demos

This section contains step-by-step instructions to execute each of the demos.

### Pre-requisites

The following should be installed for the demos to work:

* [emscripten](https://emscripten.org/docs/getting_started/downloads.html) for the `asm.js` and WebAssembly demos
* [http-service (node.js)](https://www.npmjs.com/package/http-server) to serve the "primes" example site (any simple web server will do)
* [Blazor](https://jlik.me/fhs) has full instructions for installing and using Blazor

### Build asm.js

Navigate into the primes directory. First, show the speed of the JavaScript version.

`cat primes-js.js`

`node primes-js.js`

Next, show the C code.

`cat primes.c`

Then, compile the C code to asm.js:

`emcc primes.asm.c -s WASM=0 -Os -o primes.asm.js`

Show the expanded code for reference, then run the asm.js version:

`cat primes-asm.js`

`node primes-asm.js`

### Build WebAssembly (Wasm)

Show the C code:

`cat primes.wasm.c`

Compile the C code to WebAssembly:

`emcc primes.wasm.c -s WASM=1 -Os -o primes.wasm.js`

Use a simple server like `http-server` to serve files in the directory. Navigate to `primes.html`:

[http://localhost:8080/primes.html](http://localhost:8080/primes.html)

Open the console and show the time with JavaScript vs. WebAssembly.

### Get Started

Create a new Blazor project with .NET Core hosting. Run the application and step through the tabs.

1. Note the counter resets to zero when you return
2. Show the `Shared` project defines a `WeatherForecast` class that is shared between the client and the server
3. Demonstrate service registration in `Startup`
4. Open `Startup` on the client for similar services
5. Walk through logic for `Counter.cshtml`
6. Point out that `FetchData.cshtml` uses the `HttpClient` but it is injected for the correct configuration
7. Activate network debugging in the browser. Refresh and show the DLLs being loaded

### Reusable Components

Create a new Blazor project (no hosting, client only).

1. Under `Shared` create a text file but name it `LabelSlider.cshtml`
2. Paste the following html:

   ```html
   <input type="range" min="@Min" max="@Max" bind="@CurrentValue" />
   <span>@CurrentValue</span>
   ```

3. In a `@functions` block add:

   ```csharp
    [Parameter]
    int Min { get; set; }

    [Parameter]
    int Max { get; set; }

    [Parameter]
    int CurrentValue { get; set; }
    ```

4. Drop into the `Counter` page:

   ```html
   <LabelSlider Min="0" Max="99" CurrentValue="@currentCount"/>
   ```

5. Show how the clicks update the slider, but sliding doesn't update the host page. Also note that the value only updates when you stop sliding.

6. Inside `LabelSlider` change the binding to `bind-value-oninput` to refresh as it is sliding

7. Add an event for the current value changing and implement it

   ```csharp
    private int _currentValue;

    [Parameter]
    int CurrentValue
    {
        get => _currentValue;
        set
        {
            if (value != _currentValue)
            {
                _currentValue = value;
                CurrentValueChanged(value);
            }
        }
    }

    [Parameter]
    Action<int> CurrentValueChanged { get; set; }
    ```

8. Run and show it is picking up the value, but not refreshing. Explain we'll cover manual UI refresh later.

