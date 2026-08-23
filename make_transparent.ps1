Add-Type -ReferencedAssemblies "System.Drawing.dll" -TypeDefinition @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;

public class FloodFillProcessor {
    public static void RemoveBackground(string inPath, string outPath) {
        using (Bitmap bmp = new Bitmap(inPath)) {
            int width = bmp.Width;
            int height = bmp.Height;
            bool[,] visited = new bool[width, height];
            Queue<Point> queue = new Queue<Point>();

            // Push all edge pixels if they are light/near-white
            for (int x = 0; x < width; x++) {
                AddIfBackground(bmp, x, 0, queue, visited);
                AddIfBackground(bmp, x, height - 1, queue, visited);
            }
            for (int y = 0; y < height; y++) {
                AddIfBackground(bmp, 0, y, queue, visited);
                AddIfBackground(bmp, width - 1, y, queue, visited);
            }

            int[] dx = { 1, -1, 0, 0 };
            int[] dy = { 0, 0, 1, -1 };

            while (queue.Count > 0) {
                Point p = queue.Dequeue();
                bmp.SetPixel(p.X, p.Y, Color.FromArgb(0, 0, 0, 0));

                for (int i = 0; i < 4; i++) {
                    int nx = p.X + dx[i];
                    int ny = p.Y + dy[i];

                    if (nx >= 0 && nx < width && ny >= 0 && ny < height && !visited[nx, ny]) {
                        Color c = bmp.GetPixel(nx, ny);
                        if (c.R > 215 && c.G > 215 && c.B > 215) {
                            visited[nx, ny] = true;
                            queue.Enqueue(new Point(nx, ny));
                        }
                    }
                }
            }

            bmp.Save(outPath, ImageFormat.Png);
        }
    }

    private static void AddIfBackground(Bitmap bmp, int x, int y, Queue<Point> q, bool[,] visited) {
        if (!visited[x, y]) {
            Color c = bmp.GetPixel(x, y);
            if (c.R > 215 && c.G > 215 && c.B > 215) {
                visited[x, y] = true;
                q.Enqueue(new Point(x, y));
            }
        }
    }
}
"@

$in = Resolve-Path "images/king.png"
$out = [System.IO.Path]::Combine((Get-Location).Path, "images/king_transparent.png")
[FloodFillProcessor]::RemoveBackground($in.Path, $out)
Write-Host "Flood fill finished successfully."
