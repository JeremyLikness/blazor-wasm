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

### Libraries and Interop

Create a new client-only project.

1. In NuGet packages, search for and install `MarkDig`
2. In `Index.cshtml` add the following HTML:

    ```html
    <textarea style="width: 100%" rows="5" bind="@SourceText"></textarea>
    <button onclick="@Convert">Convert</button>
    <p>@TargetText</p>
    ```

3. Add a `@functions` block:

    ```csharp
    string SourceText { get; set; }
    string TargetText { get; set; }

    void Convert()
    {
        TargetText = Markdig.Markdown.ToHtml(SourceText);
    }
    ```

4. Run and show the conversion. Explain that the bindings are "safe" and don't expand the HTML.

5. Create a file under `wwwroot` called `markupExtensions.js` and populate it with:

    ```javascript
    window.markupExtensions = {
        toHtml: (txt, target) => {
            const area = document.createElement("textarea");
            area.innerHTML = txt;
            target.innerHTML = area.value;
        }
    }
    ```

6. Reference it from `index.html` under `wwwroot` with `<script src="./markupExtensions.js"></script>`
7. In `index.cshtml` remove the `TargetText` references and inject the JavaScript interop: `@inject IJSRuntime JsRuntime`
8. Change the paragraph element to a reference: `<p ref="Target"/>`
9. Update the `@functions` to call the JavaScript via interop

    ```csharp
    string SourceText { get; set; }

    ElementRef Target;

    void Convert()
    {
        var html = Markdig.Markdown.ToHtml(SourceText);
        JsRuntime.InvokeAsync<object>("markupExtensions.toHtml", html, Target);
    }
    ```

10. Explain `Convert` could be `async` and await a response if necessary

11. Add a class named `Markdown`

    ```csharp
    public static class Markdown
    {
        [JSInvokable]
        public static string Convert(string src)
        {
            return Markdig.Markdown.ToHtml(src);
        }
    }
    ```

12. Re-run the app and from the console type:

    ```javascript
    alert(DotNet.invokeMethod("LibrariesInterop", "Convert", "# heading \n## sub-heading"))
    ```

13. Explain this can also use `Task` to make it asynchronous

### Code Behind

Create a new client-only project.

1. Create a class named `FetchDataBase` (not to be confused with a database)

    ```csharp
    public class FetchDataBase : ComponentBase
    {
        [Inject]
        public HttpClient Http { get; set; }

        public WeatherForecast[] forecasts;

        protected override async Task OnInitAsync()
        {
            forecasts = await Http.GetJsonAsync<WeatherForecast[]>
                ("sample-data/weather.json");
        }

        public class WeatherForecast
        {
            public DateTime Date { get; set; }

            public int TemperatureC { get; set; }

            public int TemperatureF { get; set; }

            public string Summary { get; set; }
        }
    }
    ```

2. Open `FetchData.cshtml` and remove the `@Inject` line and entire `@functions` block
3. Add `@inherits FetchDataBase` after the `@page` directive
4. Run it and show it working

### MVVM Pattern

Create a new client-only project.

1. Add a class named `MainModel`

    ```csharp
    public class MainModel : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;

        private int _age = 30;

        public int Age
        {
            get => _age;
            set
            {
                if (value != _age)
                {
                    _age = value;
                    PropertyChanged?.Invoke(value, new PropertyChangedEventArgs(nameof(Age)));
                }
            }
        }

        public int MaximumHeartRate
        {
            get
            {
                return 220 - _age;
            }
        }

        public int TargetHeartRate
        {
            get
            {
                return (int)(208 - (_age * 0.7));
            }
        }
    }
    ```

1. Register the class in `Startup`

    `services.AddSingleton<MainModel>();`
1. Under `Shared` add `Age.cshtml`

    ```html
    @inject MainModel Model
    Age: <span style="cursor: pointer" onclick="@(()=>Decrement(true))">
        <strong>&nbsp;&lt;&nbsp;</strong>
    </span>
    <input type="range" min="13" max="120" bind-value-oninput="Model.Age" />
    <span style="cursor: pointer" onclick="@(()=>Decrement(false))">
        <strong>&nbsp;&gt;&nbsp;</strong>
    </span>
    <span>@Model.Age</span>
    ```

1. Add the functions block:

    ```csharp
    void Decrement(bool decrement)
    {
        if (decrement && Model.Age > 13)
        {
            Model.Age -= 1;
        }
        if (!decrement && Model.Age < 120)
        {
            Model.Age += 1;
        }
    }
    ```

1. Then add `HeartRate.cshtml`

    ```html
    @inject MainModel Model
    <div>
        <p>Your target heart rate is: @Model.TargetHeartRate</p>
        <p>Your maximum heart rate is: @Model.MaximumHeartRate</p>
    </div>
    ```

1. Add the new controls to `Index.cshtml`:

    ```html
    <Age/>
    <HeartRate/>
    ```

1. Run the app and show that the heart rates aren't updating
1. Add this `@functions` code to the bottom of `HeartRate.cshtml`

    ```csharp
    protected override void OnInit()
    {
        base.OnInit();
        Model.PropertyChanged += (o, e) => StateHasChanged();
    }
    ```

1. Re-run the app and show it working
1. Explain that this can be done at a higher level to automatically propagate across controls
