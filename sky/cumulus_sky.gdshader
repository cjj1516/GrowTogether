shader_type sky;

group_uniforms Transform;
uniform float zoom = 1.0;
uniform vec2 pan = vec2(0.0);
uniform float rotation = 0.0;
group_uniforms Style;
uniform vec4 tint : source_color = vec4(1.0);

uniform float cellSize = 2.0;

#define uResolution vec2(640.0, 360.0)

#define time 0.0
const float noiseScale = 4.0;
#define screenSize vec2(640.0, 360.0)
#define sampleOffset vec2(0.0)

#define morphPhase 0.0
#define spinPhase 0.0
const float orbitRadius = 0.6;
#define scrollSpeed vec2(0.25, 0.25)
const vec2 loopD = vec2(0.0, 0.0);
const float jitter = 0.7;
const float minkowskiP = 1.8;
const float starPoints = 6.0;
const float starDepth = 0.0;
const float cellStretch = 1.0;
const float cellAngle = 67.5;
const float cellRadius = 0.6;
const float smoothK = 0.3;
const float edgeSharpen = 3.0;
const float octaves = 5.0;
const float gain = 0.6;

const vec4 PALETTE[110] = vec4[110](
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.433497,0.651623,0.935511,1.0),
  vec4(0.456674,0.665513,0.93424,1.0),
  vec4(0.48007,0.67954,0.93297,1.0),
  vec4(0.503688,0.693706,0.9317,1.0),
  vec4(0.527534,0.708013,0.93043,1.0),
  vec4(0.546276,0.719397,0.929672,1.0),
  vec4(0.565125,0.730849,0.928914,1.0),
  vec4(0.584084,0.742369,0.928156,1.0),
  vec4(0.603153,0.753958,0.927398,1.0),
  vec4(0.622334,0.765616,0.926641,1.0),
  vec4(0.641627,0.777345,0.925883,1.0),
  vec4(0.661035,0.789146,0.925125,1.0),
  vec4(0.680558,0.801018,0.924367,1.0),
  vec4(0.700198,0.812964,0.923609,1.0),
  vec4(0.719956,0.824983,0.922852,1.0),
  vec4(0.739833,0.837077,0.922094,1.0),
  vec4(0.759831,0.849246,0.921336,1.0),
  vec4(0.779951,0.861491,0.920578,1.0),
  vec4(0.800194,0.873813,0.91982,1.0),
  vec4(0.798279,0.873276,0.920942,1.0),
  vec4(0.79639,0.872752,0.922063,1.0),
  vec4(0.794525,0.872243,0.923185,1.0),
  vec4(0.792684,0.871747,0.924306,1.0),
  vec4(0.790867,0.871264,0.925428,1.0),
  vec4(0.789074,0.870795,0.926549,1.0),
  vec4(0.787303,0.870338,0.92767,1.0),
  vec4(0.785556,0.869894,0.928792,1.0),
  vec4(0.78383,0.869463,0.929913,1.0),
  vec4(0.782127,0.869044,0.931035,1.0),
  vec4(0.780445,0.868638,0.932156,1.0),
  vec4(0.778784,0.868243,0.933277,1.0),
  vec4(0.785867,0.872364,0.934661,1.0),
  vec4(0.792891,0.876456,0.936045,1.0),
  vec4(0.799857,0.880521,0.937429,1.0),
  vec4(0.806767,0.884559,0.938813,1.0),
  vec4(0.813621,0.888571,0.940197,1.0),
  vec4(0.820421,0.892557,0.941581,1.0),
  vec4(0.827166,0.896518,0.942965,1.0),
  vec4(0.83386,0.900453,0.944349,1.0),
  vec4(0.840501,0.904365,0.945732,1.0),
  vec4(0.847093,0.908252,0.947116,1.0),
  vec4(0.853634,0.912116,0.9485,1.0),
  vec4(0.860127,0.915957,0.949884,1.0),
  vec4(0.866571,0.919775,0.951268,1.0),
  vec4(0.87297,0.92357,0.952652,1.0),
  vec4(0.875506,0.925196,0.95233,1.0),
  vec4(0.878043,0.926823,0.952007,1.0),
  vec4(0.880579,0.928449,0.951685,1.0),
  vec4(0.883116,0.930075,0.951362,1.0),
  vec4(0.885652,0.931701,0.95104,1.0),
  vec4(0.888189,0.933327,0.950718,1.0),
  vec4(0.890725,0.934953,0.950395,1.0),
  vec4(0.893262,0.93658,0.950073,1.0),
  vec4(0.895799,0.938206,0.949751,1.0),
  vec4(0.898335,0.939832,0.949428,1.0),
  vec4(0.900872,0.941458,0.949106,1.0),
  vec4(0.903408,0.943084,0.948783,1.0),
  vec4(0.905945,0.94471,0.948461,1.0),
  vec4(0.908481,0.946337,0.948139,1.0),
  vec4(0.911018,0.947963,0.947816,1.0),
  vec4(0.913554,0.949589,0.947494,1.0),
  vec4(0.916091,0.951215,0.947171,1.0),
  vec4(0.918627,0.952841,0.946849,1.0),
  vec4(0.921164,0.954467,0.946527,1.0),
  vec4(0.923701,0.956094,0.946204,1.0),
  vec4(0.926237,0.95772,0.945882,1.0),
  vec4(0.928774,0.959346,0.94556,1.0),
  vec4(0.93131,0.960972,0.945237,1.0),
  vec4(0.933847,0.962598,0.944915,1.0),
  vec4(0.936383,0.964224,0.944592,1.0),
  vec4(0.93892,0.965851,0.94427,1.0),
  vec4(0.941456,0.967477,0.943948,1.0),
  vec4(0.943993,0.969103,0.943625,1.0),
  vec4(0.94653,0.970729,0.943303,1.0),
  vec4(0.949066,0.972355,0.942981,1.0),
  vec4(0.951603,0.973981,0.942658,1.0),
  vec4(0.954139,0.975608,0.942336,1.0),
  vec4(0.956676,0.977234,0.942013,1.0),
  vec4(0.959212,0.97886,0.941691,1.0),
  vec4(0.961749,0.980486,0.941369,1.0),
  vec4(0.964285,0.982112,0.941046,1.0),
  vec4(0.966822,0.983738,0.940724,1.0),
  vec4(0.969359,0.985365,0.940401,1.0),
  vec4(0.971895,0.986991,0.940079,1.0),
  vec4(0.974432,0.988617,0.939757,1.0),
  vec4(0.976968,0.990243,0.939434,1.0),
  vec4(0.979505,0.991869,0.939112,1.0),
  vec4(0.982041,0.993495,0.93879,1.0),
  vec4(0.984578,0.995122,0.938467,1.0),
  vec4(0.987114,0.996748,0.938145,1.0),
  vec4(0.989651,0.998374,0.937822,1.0),
  vec4(0.992188,1.0,0.9375,1.0)
);
vec4 paletteLookup(float x){
  int i = clamp(int(clamp(x,0.0,1.0)*256.0),0,255);
  return PALETTE[clamp(int(float(i)/255.0*110.0),0,109)];
}

#define TAU 6.28318530718
#define MAX_OCTAVES 10

vec2 latticeOffset(vec2 cell) {
    float row = floor(cell.y);
    
    return vec2(mod(row, 2.0) * 0.5, 0.0);
}

vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453);
}

vec2 wrapCell(vec2 cell, float angN, vec2 d) {
    if (angN > 0.5) cell.x = mod(cell.x, angN);
    
    return cell;
}

float metricDist(vec2 d, float ang) {
    float s = sin(ang), c = cos(ang);
    d = mat2(vec2(c, -s), vec2(s, c)) * d;
    d.x *= cellStretch; d.y /= cellStretch;
    float p  = max(minkowskiP, 0.1);
    float md = pow(pow(abs(d.x), p) + pow(abs(d.y), p), 1.0 / p);
    return md * (1.0 + starDepth * cos(starPoints * atan(d.y, d.x)));
}

float cellSpin(vec2 cell) {
    float turns = cellAngle / 360.0;
    turns += spinPhase;
    return -turns * TAU;
}

float smin(float a, float b, float k) {
    if (k <= 0.0) return min(a, b);
    float h = clamp(0.5 + 0.5 * (a - b) / k, 0.0, 1.0);
    return mix(a, b, h) - k * h * (1.0 - h);
}

void consider(float d, inout float f1, inout float f2) {
    if      (d < f1) f2 = f1;
    else if (d < f2) f2 = d;
    f1 = smin(f1, d, smoothK);
}

float comboValue(float f1, float f2) {
    float s = 1.0 / max(cellRadius, 0.001);
    f1 *= s; f2 *= s;
    float v;
    v = sqrt(max(1.0 - f1 * f1, 0.0));
    v = clamp(v, 0.0, 1.0);
    v = pow(v, edgeSharpen);
    
    return clamp(v, 0.0, 1.0);
}

vec2 warpUV(vec2 uv) {
    return uv;
}

vec2 rotateUV(vec2 uv) {
    return uv;
}

#define CELL_EMPTY_LO 4.0
#define CELL_EMPTY_HI 7.0
#define CELL_EMPTY_VALUE 1.0



float cellFinish(float f1, float f2, bool doCells) {
    float v = comboValue(f1, f2);
    if (doCells) v = mix(v, CELL_EMPTY_VALUE, smoothstep(CELL_EMPTY_LO, CELL_EMPTY_HI, f1));
    
    return v;
}

float cellOrbit(vec2 p, float angN, vec2 d, bool isBase) {

    vec2 ip = floor(p), fp = fract(p);
    float f1 = 8.0, f2 = 8.0;
    for (int j = -2; j <= 2; j++) {
        for (int i = -2; i <= 2; i++) {
            vec2 g    = vec2(float(i), float(j));
            vec2 cell = wrapCell(ip + g, angN, d);
            vec2 rnd  = hash2(cell);
            vec2 anim = 0.5 + orbitRadius * sin(morphPhase * TAU + rnd * TAU);
            vec2 pt   = g + mix(vec2(0.5), anim, jitter);
            pt += latticeOffset(cell) * (1.0 - jitter);
            
            float d = metricDist(pt - fp, cellSpin(cell));
            
            consider(d, f1, f2);
        }
    }
    
    return cellFinish(f1, f2, false);
}

float cellEval(vec2 p, float angN, vec2 d, bool isBase) {
    return cellOrbit(p, angN, d, isBase);
}

float cellFBM(vec2 p, float angN) {
    float v = 0.0, a = 0.5, norm = 0.0;
    vec2  d = loopD;
    int oct = int(octaves + 0.5);
    for (int i = 0; i < MAX_OCTAVES; i++) {
        if (i >= oct) break;
        v    += a * cellEval(p, angN, d, i == 0);
        norm += a;
        p     = p * 2.0 + vec2(5.3, 1.7);
        a    *= gain;
        if (angN > 0.5) angN *= 2.0;

        d    *= 2.0;
    }
    return v / norm;
}

vec4 shade(vec2 screen_coords) {
    vec2 block = floor((screen_coords + sampleOffset) / cellSize) * cellSize;
    vec2 uv0   = warpUV(block / screenSize);
    float mzAdd = 0.0, valAdd = 0.0;
    vec2 uvDisp = vec2(0.0);

    vec2 uv = rotateUV(uv0 + uvDisp);

    vec2  p;
    float angN = 0.0;
    {
        p = uv * noiseScale + time * scrollSpeed;
    }
    p.y *= 1.1547;

    float v = cellFBM(p, angN);
    v = clamp(v + valAdd, 0.0, 1.0);

    return paletteLookup(v);
}


void sky(){
  vec2 uv = EYEDIR.xz / max(1.0 + EYEDIR.y, 1e-3) * 0.5;
  float s = sin(rotation), cs = cos(rotation);
  uv = mat2(vec2(cs, -s), vec2(s, cs)) * uv;
  uv = uv / zoom + pan;
  vec4 c = shade((uv + 0.5) * vec2(640.0, 360.0));
  COLOR = c.rgb * tint.rgb;
}