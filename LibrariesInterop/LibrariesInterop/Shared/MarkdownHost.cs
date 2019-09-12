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