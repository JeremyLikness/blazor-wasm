# Blazor and WebAssembly

[![Build Status](https://jeremylikness.visualstudio.com/blazor-wasm/_apis/build/status/JeremyLikness.blazor-wasm?branchName=master)](https://jeremylikness.visualstudio.com/blazor-wasm/_build/latest?definitionId=9&branchName=master)

![Release Status](https://jeremylikness.vsrm.visualstudio.com/_apis/public/Release/badge/924b10c3-4fcd-47eb-8b03-35e40f04e862/1/1)

[![Free Azure Account](https://img.shields.io/badge/FREE-Azure-0077ff)](https://jlik.me/gmi) Get your [Free Azure Account](https://jlik.me/gmi)

This repository contains samples for a presentation about using C# and .NET in the browser using WebAssembly with Blazor.

▶ [Get Started with Blazor](https://jlik.me/flj) 

👋🏻 [Introduction/Overview of Blazor](https://jlik.me/flk)

🔪 [Intro to Razor Components](https://jlik.me/fll)

> This repository is continuously built and deployed using free Azure Pipelines. If you're interested in how it was setup and configured to build automatically and deploy to low cost Azure Storage Static Websites, read [Deploy WebAssembly from GitHub to Azure Storage Static Websites with Azure Pipelines](https://jlik.me/fzh).

## Presentation

🎦 You can download the related PowerPoint presentation [here](https://jlik.me/fn3).

To see how Blazor compares to other SPA frameworks like Angular, read: [Angular vs. Blazor](https://blog.jeremylikness.com/blog/2019-01-03_from-angular-to-blazor-the-health-app/).

## Demos

This section contains step-by-step instructions to execute each of the demos.

### Pre-requisites

The following should be installed for the demos to work:

* [emscripten](https://emscripten.org/docs/getting_started/downloads.html) for the `asm.js` and WebAssembly demos
* [http-service (node.js)](https://www.npmjs.com/package/http-server) to serve the "primes" example site (any simple web server will do)
* [Blazor](https://jlik.me/fhs) has full instructions for installing and using Blazor.

The current version used in this repo is `3.0.0-preview9.19424.4`.

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

👀 [Live Demo](https://jlikme.z13.web.core.windows.net/blazor-wasm/primes/primes.html)

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
5. Walk through logic for `Counter.razor`
6. Point out that `FetchData.razor` uses the `HttpClient` but it is injected for the correct configuration
7. Activate network debugging in the browser. Refresh and show the DLLs being loaded

### Reusable Components

👀 [Live Demo](https://jlikme.z13.web.core.windows.net/blazor-wasm/ReusableComponents)

Create a new Blazor project (no hosting, client only).

1. Under `Shared` create a Razor view component and name it `LabelSlider.razor`
2. Paste the following html:

   ```html
   <input type="range" min="@Min" max="@Max" @bind="@CurrentValue" />
   <span>@CurrentValue</span>
   ```

3. In a `@code` block add:

   ```csharp
    [Parameter]
    public int Min { get; set; }

    [Parameter]
    public int Max { get; set; }

    [Parameter]
    public int CurrentValue { get; set; }
    ```

4. Drop into the `Counter` page:

   ```html
   <LabelSlider Min="0" Max="99" CurrentValue="@currentCount"/>
   ```

5. Show how the clicks update the slider, but sliding doesn't update the host page. Also note that the value only updates when you stop sliding, and it only updates on the slider and not on the "current count" (although clicking the button will update the slider, the converse isn't true.)

6. Inside `LabelSlider` change the binding to `@bind-value="@CurrentValue"` then add an additional `@bind-value:event="oninput"` to refresh as it is sliding

7. Add an event for the current value changing and implement it (this will replace the existing `CurrentValue` property)

   ```csharp
    private int _currentValue;

    [Parameter]
    public int CurrentValue
    {
        get => _currentValue;
        set
        {
            if (value != _currentValue)
            {
                _currentValue = value;
                CurrentValueChanged?.Invoke(value);
            }
        }
    }

    [Parameter]
    public Action<int> CurrentValueChanged { get; set; }
    ```

8. Update the binding to `@bind-CurrentValue` in `Counter.razor`
9. Run and show it is picking up the value, but not refreshing. Explain we'll cover manual UI refresh later.

### Libraries and Interop

👀 [Live Demo](https://jlikme.z13.web.core.windows.net/blazor-wasm/LibrariesInterop)

Create a new client-only project.

1. In NuGet packages, search for and install `Markdown` [here](https://www.nuget.org/packages/Markdown/)
2. In `Index.razor` add the following HTML (remove the `SurveyPrompt`):

    ```html
    <textarea style="width: 100%" rows="5" @bind="@SourceText"></textarea>
    <button @onclick="@Convert">Convert</button>
    <p>@TargetText</p>
    ```

3. Add a `@using HeyRed.MarkdownSharp` to the top
4. Add a `@code` block:

    ```csharp
    string SourceText { get; set; }
    string TargetText { get; set; }
    Markdown markdown = new Markdown();

    void Convert()
    {
        TargetText = markdown.Transform(SourceText);
    }
    ```

5. Run and show the conversion. Explain that the bindings are "safe" and don't expand the HTML.

6. Create a file under `wwwroot` called `markupExtensions.js` and populate it with:

    ```javascript
    window.markupExtensions = {
        toHtml: (txt, target) => {
            const area = document.createElement("textarea");
            area.innerHTML = txt;
            target.innerHTML = area.value;
        }
    }
    ```

7. Reference it from `index.html` under `wwwroot` with `<script src="./markupExtensions.js"></script>`
8. In `index.razor` remove the `TargetText` references and inject the JavaScript interop: `@inject IJSRuntime JsRuntime`
9. Change the paragraph element to a reference: `<p @ref="Target"/>`
10. Update the `@code` to call the JavaScript via interop

    ```csharp
    string SourceText { get; set; }
    ElementReference Target;
    Markdown markdown = new Markdown();

    void Convert()
    {
        var html = markdown.Transform(SourceText);
        JsRuntime.InvokeAsync<object>("markupExtensions.toHtml", html, Target);
    }
    ```

11. Run and show the goodness. Explain `Convert` could be `async` and await a response if necessary

12. Add a class named `MarkdownHost` under `Shared`:

    ```csharp
    using HeyRed.MarkdownSharp;
    using Microsoft.JSInterop;

    namespace LibrariesInterop.Shared
    {
        public static class MarkdownHost
        {
            [JSInvokable]
            public static string Convert(string src)
            {
                return new Markdown().Transform(src);
            }
        }
    }
    ```

13. Re-run the app and from the console type. Be sure to change `LibrariesInterop` to the name of your project:

    ```javascript
    alert(DotNet.invokeMethod("LibrariesInterop", "Convert", "# one\n## two \n* a \n* b"))
    ```

14. Explain this can also use `Task` to make it asynchronous

### Code Behind

👀 [Live Demo](https://jlikme.z13.web.core.windows.net/blazor-wasm/CodeBehind)

Create a new client-only project.

1. Create a class under `Pages` named `FetchDataBase` (not to be confused with a database)

    ```csharp
    public class FetchDataBase : ComponentBase
    {
        [Inject]
        public HttpClient Http { get; set; }

        public WeatherForecast[] forecasts;

        protected override async Task OnInitializedAsync()
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
    
    These are the using statements:
    
    ```csharp
    using Microsoft.AspNetCore.Components;
    using System;
    using System.Net.Http;
    using System.Threading.Tasks;
    ```

2. Open `FetchData.razor` and remove the `@Inject` line and entire `@code` block
3. Add `@inherits FetchDataBase` after the `@page` directive
4. Run it and show it working

### MVVM Pattern

👀 [Live Demo](https://jlikme.z13.web.core.windows.net/blazor-wasm/MvvmPattern)

Create a new client-only project.

1. Add a class named `MainModel` to the root

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
                return (int)(0.85*MaximumHeartRate);
            }
        }
    }
    ```

    Add a using for `System.ComponentModel`

1. Register the class in `Startup` under `ConfigureServices`

    `services.AddSingleton<MainModel>();`

1. Under `Shared` add `Age.razor`

    ```html
    @inject MainModel Model
    Age: <span style="cursor: pointer" @onclick="@(()=>Decrement(true))">
    <strong>&nbsp;&lt;&nbsp;</strong>
    </span>
    <input type="range" min="13" max="120" @bind-value="Model.Age"
       @bind-value:event="oninput" />
    <span style="cursor: pointer" @onclick="@(()=>Decrement(false))">
        <strong>&nbsp;&gt;&nbsp;</strong>
    </span>
    <span>@Model.Age</span>
    ```

1. Add the code block:

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

1. Then add `HeartRate.razor` under `Shared`:

    ```html
    @inject MainModel Model
    <div>
        <p>Your target heart rate is: @Model.TargetHeartRate</p>
        <p>Your maximum heart rate is: @Model.MaximumHeartRate</p>
    </div>
    ```

1. Add the new controls to `Index.razor` (remove `SurveyPrompt`):

    ```html
    <Age/>
    <HeartRate/>
    ```

1. Run the app and show that the heart rates aren't updating
1. Add this `@code` code to the bottom of `HeartRate.razor`

    ```csharp
    protected override void OnInitialized()
    {
        base.OnInitialized();
        Model.PropertyChanged += (o, e) => StateHasChanged();
    }
    ```

1. Re-run the app and show it working
1. Explain that this can be done at a higher level to automatically propagate across controls

Learn more about: [MVVM support in Blazor](https://blog.jeremylikness.com/blog/2019-01-04_mvvm-support-in-blazor/).

### Debugging

1. Open URL in Chrome for any of the apps
2. Show `SHIFT+ALT+D` key press
3. If instructions appear, close all Chrome instances (including in the system tray) and paste the code to run with debugging enabled
4. Repeat the key press
5. Show a breakpoint and discuss this is very limited for now

## Summary
▶ [Get Started with Blazor](https://jlik.me/flj)

👋🏻 [Introduction/Overview of Blazor](https://jlik.me/flk)

🔪 [Intro to Razor Components](https://jlik.me/fll)  
