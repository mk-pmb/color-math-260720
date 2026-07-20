const EX = { // luminance, colorfulness, greyishness

  greyFracToByte(x) { return Math.min(Math.round(x * 255), 255); },
  rgbScale(s, c) { return { r: s * c.r, g: s * c.g, b: s * c.b }; },
  rgbToArray(c) { return [c.r, c.g, c.b]; },
  rgbDotProduct(v, w) { return ((v.r * w.r) + (v.g * w.g) + (v.b * w.b)); },

  sRGBperceivedLuminanceFactors: { r: 0.2126, g: 0.7152, b: 0.0722 }, /*
    CIE Rec. 709 coefficients from section "Use of relative luminance" on
    https://en.wikipedia.org/wiki/Luma_%28video%29?oldid=1351363170 */

  makeRgbTransformer(t) {
    return function f(c) { return { r: t(c.r), g: t(c.g), b: t(c.b) }; };
  },

  chromaticSpread(c) {
    const a = EX.rgbToArray(c);
    return Math.max(...a) - Math.min(...a);
  },

  greyByteInputProxy(f) { return function g(b) { return f(b / 255); }; },

  rgbBytesInputProxy(f) {
    return function g(c) { return f(EX.rgbScale(1 / 255, c)); };
  },

  greyByteOutputProxy(f) {
    return function g(x) { return EX.greyFracToByte(f(x)); };
  },

  rgbBytesToGreyByteProxy(f) {
    return EX.greyByteOutputProxy(EX.rgbBytesInputProxy(f));
  };

  approxColorfulnessRatio(rgb) { // color as fractions 0..1
    const Y = EX.sRGBperceivedLuminance(rgb);
    const C = (Y && (EX.chromaticSpread(rgb) / Y));
    return C;
    /* C_min = 0 (all greys)
      C_green ≈ 1.40, C_red ≈ 4.70, C_blue ≈ 13.85

      Those are the inverse of their luminance factors because pure colors
      have maximum chromatic spread (1.0) and no other color channel
      contributes anything. The "maximum chromatic spread" argument also
      means C_max must be one of them, and thus:

      C_max = C_blue */
  },

  approxColorfulnessFrac(rgb) {
    const C = EX.approxColorfulnessRatio(rgb);
    /* The standard approach would be C / C_max. However, float division
      is lossful, and we already had one to calculate C. From the C_max
      argument above, we know that C_max = C_blue = 1 / lumfac_B,
      so we can instead just multiply lumfac_B: */
    return C * EX.sRGBperceivedLuminanceFactors.b;
  },

};


// function compose(f, g) { return x => g(f(x)); }

EX.sRGBperceivedLuminance = EX.rgbDotProduct.bind(null,
  EX.sRGBperceivedLuminanceFactors);

EX.rgbFracToByte = EX.makeRgbTransformer(EX.greyFracToByte);

EX.approxColorfulnessByte = EX.rgbBytesToGreyByteProxy(
  approxColorfulnessFrac);



export default EX;
