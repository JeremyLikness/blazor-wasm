using Microsoft.JSInterop;

namespace LibrariesInterop.Shared
{
    public static class Markdown
    {
        [JSInvokable]
        public static string Convert(string src)
        {
            return Markdig.Markdown.ToHtml(src);
        }
    }
}
