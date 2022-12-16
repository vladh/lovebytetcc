use fmt;
use math;
use rt;
use sdl2::{ SDL_RendererFlags, SDL_WindowFlags, SDL_EventType, SDL_TextureAccess };
use sdl2;
use strings;

export fn main() void = {
	match (run()) {
	case let err: sdl2::error =>
		fmt::fatal("SDL2 error: {}", sdl2::strerror(err));
	case void => void;
	};
};

fn run() (void | sdl2::error) = {
	const width = 1280;
	const height = 800;

	sdl2::SDL_Init(sdl2::SDL_INIT_VIDEO)!;
	defer sdl2::SDL_Quit();

	const window = sdl2::SDL_CreateWindow("",
		sdl2::SDL_WINDOWPOS_UNDEFINED, sdl2::SDL_WINDOWPOS_UNDEFINED,
		width, height, SDL_WindowFlags::SHOWN)?;
	defer sdl2::SDL_DestroyWindow(window);

	const renderer = sdl2::SDL_CreateRenderer(window, -1,
		SDL_RendererFlags::ACCELERATED | SDL_RendererFlags::PRESENTVSYNC)?;
	defer sdl2::SDL_DestroyRenderer(renderer);

	const pixels = sdl2::SDL_CreateTexture(renderer,
		sdl2::SDL_PIXELFORMAT_ARGB8888, SDL_TextureAccess::STREAMING, width, height)!;

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

		rt::memset(data: *void, 0, (pitch * height): size);

		for (let y = 0i; y < height; y += 1) {
			for (let x = 0i; x < width; x += 1) {
				let row: uintptr = data: uintptr + (pitch * y): uintptr;
				let pixel = (row + (x * size(uint): int): uintptr): *uint;
				*pixel = get_pixel(x, y, t, dt);
			};
		};

		sdl2::SDL_UnlockTexture(pixels);

		sdl2::SDL_RenderCopy(renderer, pixels, null, null)!;
		sdl2::SDL_RenderPresent(renderer);
	};
};

fn get_pixel(x: int, y: int, t: f64, dt: f64) uint = {
	let color: u32 = 0xff000000;
	let r = (math::sinf64(t) * 256f64 / 8f64): u32;
	let g = (math::sinf64(t) * 256f64 / 2f64): u32;
	let b = (math::sinf64(t) * 256f64): u32;
	color = color | (r << (4 * 4)) | (g << (4 * 2)) | b;
	return color;
};
