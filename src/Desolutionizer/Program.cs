using System;
using System.IO;
using System.Text;
using System.Xml.Linq;

namespace Desolutionizer
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 1 || !File.Exists(args[0]))
            {
                Console.WriteLine("Incorrect usage. Desolutionizer <PathToExistingSolution>");
            }

            var solutionFile = Path.GetFullPath(args[0]);

            var sb = new StringBuilder();

            sb.Append("<Project DefaultTargets=\"Build\">");

            sb.Append("<ItemGroup>");

            sb.Append("<ProjectReferenceTargets Include=\"Build\" Targets=\"Build\" />");

            foreach (var projectFile in CommonUtilities.SolutionParser.GetProjectFiles(solutionFile))
            {
                sb.Append($"<ProjectReference Include=\"{projectFile}\" />");
            }


            sb.Append("</ItemGroup>");

            sb.Append(@"
<Target Name=""Build"">
    <MSBuild Projects=""@(ProjectReference)"" BuildInParallel=""true"" Condition=""'$(IsGraphBuild)'!='true'""/>
</Target>");

            sb.Append("</Project>");

            var msbuildFile = Path.Combine(Path.GetDirectoryName(solutionFile), $"{Path.GetFileNameWithoutExtension(solutionFile)}.proj");

            XDocument.Parse(sb.ToString()).Save(msbuildFile);
        }
    }
}
