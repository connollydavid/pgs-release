/* Quantizer benchmark: quality (round-trip PSNR) and speed (Mpixels/s)
 * for each AVQuantizeAlgorithm across resolutions and palette sizes.
 * Methodology: deterministic PRNG RGB input, generate_palette + apply
 * per algorithm, timed with clock(); PSNR computed on the dequantized
 * RGB reconstruction mapped back through the palette. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>
#include "libavutil/quantize.h"
#include "libavutil/mem.h"

static double psnr_rgb(const uint8_t *a, const uint8_t *b, size_t n)
{
    double sse = 0.0;
    for (size_t i = 0; i < n; i++) {
        int d = (int)a[i] - (int)b[i];
        sse += d * d;
    }
    if (sse <= 0.0)
        return 99;
    return 10 * log10(255.0 * 255.0 * n / sse);
}

int main(void)
{
    const struct { int w, h; const char *name; } res[] = {
        { 720, 480, "SD" }, { 1920, 1080, "HD" }, { 3840, 2160, "UHD" },
    };
    const int pals[] = { 16, 64, 256 };
    const struct { enum AVQuantizeAlgorithm a; const char *name; } algos[] = {
        { AV_QUANTIZE_NEUQUANT,   "NeuQuant"   },
        { AV_QUANTIZE_MEDIAN_CUT, "MedianCut"  },
        { AV_QUANTIZE_ELBG,       "ELBG"       },
    };

    printf("%-10s %-5s %4s %10s %8s\n", "algo", "res", "pal", "Mpix/s", "PSNR");
    for (unsigned ri = 0; ri < 3; ri++) {
        int w = res[ri].w, h = res[ri].h;
        int npix = w * h;
        uint8_t *rgba = av_malloc((size_t)npix * 4);
        uint8_t *out  = av_malloc((size_t)npix * 4);
        uint8_t *idx  = av_malloc(npix);
        uint32_t palette[256];
        if (!rgba || !out || !idx) return 1;
        srand(42 + ri);
        for (int i = 0; i < npix * 4; i += 4) {
            rgba[i]   = rand() & 255;
            rgba[i+1] = rand() & 255;
            rgba[i+2] = rand() & 255;
            rgba[i+3] = 255;
        }
        for (unsigned pi = 0; pi < 3; pi++) for (unsigned ai = 0; ai < 3; ai++) {
            AVQuantizeContext *q = av_quantize_alloc(algos[ai].a, pals[pi]);
            if (!q) { printf("%-10s alloc failed\n", algos[ai].name); continue; }
            int ncol = av_quantize_generate_palette(q, rgba, npix, palette, 10);
            if (ncol < 0) { printf("%-10s gen failed\n", algos[ai].name); av_quantize_freep(&q); continue; }
            clock_t t0 = clock();
            int ret = av_quantize_apply(q, rgba, idx, npix);
            double dt = (double)(clock() - t0) / CLOCKS_PER_SEC;
            if (ret < 0) { printf("%-10s apply failed\n", algos[ai].name); av_quantize_freep(&q); continue; }
            for (int px = 0; px < npix; px++) {
                uint32_t c = palette[idx[px]];
                out[px*4]   = (uint8_t)(c & 255);
                out[px*4+1] = (uint8_t)((c >> 8) & 255);
                out[px*4+2] = (uint8_t)((c >> 16) & 255);
                out[px*4+3] = 255;
            }
            double ps = psnr_rgb(rgba, out, (size_t)npix * 4);
            double mpixs = dt > 0 ? (npix / 1e6) / dt : 0;
            printf("%-10s %-5s %3d %10.2f %8.2f\n", algos[ai].name,
                   res[ri].name, pals[pi], mpixs, ps);
            av_quantize_freep(&q);
        }
        av_freep(&rgba);
        av_freep(&out);
        av_freep(&idx);
    }
    return 0;
}
