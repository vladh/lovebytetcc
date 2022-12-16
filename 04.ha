use fmt;
use math;
use math::random;
use rt;
use sdl2::{ SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_TextureAccess };
use sdl2;
use strings;

def WIDTH: int = 1280;
def HEIGHT: int = 800;
def PIXEL_SIZE: int = 3;
let COLORS: []u32 = [
	0xfff4f4f4,
	0xff73eff7,
	0xff41a6f6,
	0xff3b5dc9,
	0xff29366f,
	0xff257179,
	0xff38b764,
	0xffa7f070,
	0xffffcd75,
	0xffef7d57,
	0xffb13e53,
	0xff5d275d,
	0xff1a1c2c,
	0xff333c57,
	0xff566c86,
	0xff94b0c2,
];
def N_COLORS: u32 = 16;

export fn main() void = {
	match (run()) {
	case let err: sdl2::error =>
		fmt::fatal("SDL2 error: {}", sdl2::strerror(err));
	case void => void;
	};
};

fn run() (void | sdl2::error) = {
	sdl2::SDL_Init(sdl2::SDL_INIT_VIDEO)!;
	defer sdl2::SDL_Quit();

	const window = sdl2::SDL_CreateWindow("",
		sdl2::SDL_WINDOWPOS_UNDEFINED, sdl2::SDL_WINDOWPOS_UNDEFINED,
		WIDTH, HEIGHT, SDL_WindowFlags::SHOWN)?;
	defer sdl2::SDL_DestroyWindow(window);

	const renderer = sdl2::SDL_CreateRenderer(window, -1,
		SDL_RendererFlags::ACCELERATED)?;
	defer sdl2::SDL_DestroyRenderer(renderer);

	const pixels = sdl2::SDL_CreateTexture(renderer,
		sdl2::SDL_PIXELFORMAT_ARGB8888, SDL_TextureAccess::STREAMING, WIDTH, HEIGHT)!;

	let t_last = sdl2::SDL_GetTicks(): f64 / 1000f64;
	let t = sdl2::SDL_GetTicks(): f64 / 1000f64;

	for (true) {
		let ev = sdl2::event { ... };
		for (sdl2::SDL_PollEvent(&ev)? == 1) switch (ev.event_type) {
		case SDL_EventType::QUIT => return;
		case => void;
		};

		let t = sdl2::SDL_GetTicks(): f64 / 1000f64;
		let dt = (t - t_last);
		t_last = t;

		let data: nullable *void = null;
		let pitch = 0i;
		sdl2::SDL_LockTexture(pixels, null, &data, &pitch)!;

		rt::memset(data: *void, 0, (pitch * HEIGHT): size);

		for (let y = 0i; y < HEIGHT; y += PIXEL_SIZE) {
			for (let x = 0i; x < WIDTH; x += PIXEL_SIZE) {
				const val = get_pixel(x, y, t, dt);
				for (let py = 0i; py < PIXEL_SIZE; py += 1) {
					let row: uintptr = data: uintptr + (pitch * (y + py)): uintptr;
					for (let px = 0i; px < PIXEL_SIZE; px += 1) {
						let pixel = (row + ((x + px) * size(uint): int): uintptr): *uint;
						*pixel = val;
					};
				};
			};
		};

		sdl2::SDL_UnlockTexture(pixels);

		sdl2::SDL_RenderCopy(renderer, pixels, null, null)!;
		sdl2::SDL_RenderPresent(renderer);
	};
};

fn pos(x: f64) f64 = (x + 1f64) / 2f64;

fn to_cidx(x: f64) int = (x * ((N_COLORS: f64) - 1f64)): int;

fn maxf64(x: f64, y: f64) f64 = if (x > y) { return x; } else { return y; };

fn get_pixel(x: int, y: int, t: f64, dt: f64) uint = {
	let r = math::random::init((x + y * WIDTH): u64);
	let rx = (math::random::u64n(&r, 20000): f64 / 20000f64 * 1.005f64 - 0.5f64) * 12f64;
	let ry = (math::random::u64n(&r, 20000): f64 / 20000f64 * 1.010f64 - 0.5f64) * 14f64;
	let st = math::sinf64(t);
	let x_stretch = 11f64 + st * 1f64;
	let y_stretch = 9f64 - st * 2f64;
	let tx = t * 20f64;
	let ty = t * 10f64;
	let x_val = math::modf64(pos(math::sinf64((x: f64 + rx + tx) / WIDTH: f64 * x_stretch)) + t * 0.1f64, 1f64);
	let y_val = math::modf64(pos(math::sinf64((y: f64 + ry + ty) / HEIGHT: f64 * y_stretch)) + t * 0.1f64, 1f64);
	let color = COLORS[to_cidx(math::modf64(x_val + y_val, 1f64))];
	return color;
};
