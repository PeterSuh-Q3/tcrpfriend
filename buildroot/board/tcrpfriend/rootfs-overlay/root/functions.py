# -*- coding: utf-8 -*-
#
# Copyright (C) 2022 Ing <https://github.com/wjz304>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

import os, click

WORK_PATH = os.path.abspath(os.path.dirname(__file__))

@click.group()
def cli():
    """
    The CLI is a commands to MSHELL.
    """
    pass


def mutually_exclusive_options(ctx, param, value):
    other_option = "file" if param.name == "data" else "data"
    if value is not None and ctx.params.get(other_option) is not None:
        raise click.UsageError(f"Illegal usage: `{param.name}` is mutually exclusive with `{other_option}`.")
    return value


def validate_required_param(ctx, param, value):
    if not value and "file" not in ctx.params and "data" not in ctx.params:
        raise click.MissingParameter(param_decls=[param.name])
    return value


def __fullversion(ver):
    arr = ver.split('-')
    a, b, c = (arr[0].split('.') + ['0', '0', '0'])[:3]
    d = arr[1] if len(arr) > 1 else '00000'
    e = arr[2] if len(arr) > 2 else '0'
    return f'{a}.{b}.{c}-{d}-{e}'
    

@cli.command()
@click.option("-d", "--data", type=str, callback=mutually_exclusive_options, is_eager=True, help="The data of QRCode.")
@click.option("-f", "--file", type=str, callback=mutually_exclusive_options, is_eager=True, help="The file of QRCode.")
@click.option("--validate", is_flag=True, callback=validate_required_param, expose_value=False, is_eager=True)
@click.option("-l", "--location", type=click.IntRange(0, 7), required=True, help="The location of QRCode. (range 0<=x<=7)")
@click.option("-o", "--output", type=str, required=True, help="The output file of QRCode.")
def makeqr(data, file, location, output):
    """
    Generate a QRCode.
    """
    try:
        import fcntl, struct
        import qrcode
        from PIL import Image

        FBIOGET_VSCREENINFO = 0x4600
        FBIOPUT_VSCREENINFO = 0x4601
        FBIOGET_FSCREENINFO = 0x4602
        FBDEV = "/dev/fb0"

        if data:
            qr = qrcode.QRCode(version=1, box_size=10, error_correction=qrcode.constants.ERROR_CORRECT_H, border=4)
            qr.add_data(data)
            qr.make(fit=True)
            img = qr.make_image(fill_color="purple", back_color="white").convert("RGBA")
            pixels = img.load()
            for i in range(img.size[0]):
                for j in range(img.size[1]):
                    if pixels[i, j] == (255, 255, 255, 255):
                        pixels[i, j] = (255, 255, 255, 0)

            logo_path = os.path.join(WORK_PATH, "logo.png")
            if os.path.exists(logo_path):
                icon = Image.open(logo_path).convert("RGBA")
                img.paste(icon.resize((img.size[0] // 5, img.size[1] // 5)), ((img.size[0] - img.size[0] // 5) // 2, (img.size[1] - img.size[1] // 5) // 2))

        elif file:
            img = Image.open(file)
            # img = img.convert("RGBA")
            # pixels = img.load()
            # for i in range(img.size[0]):
            #     for j in range(img.size[1]):
            #         if pixels[i, j] == (255, 255, 255, 255):
            #             pixels[i, j] = (255, 255, 255, 0)
        else:
            raise click.UsageError("Either data or file must be provided.")

        with open(FBDEV, "rb") as fb:
            vi = fcntl.ioctl(fb, FBIOGET_VSCREENINFO, bytes(160))
            res = struct.unpack("I" * 40, vi)
            xres, yres = res[0], res[1] if res[0] and res[1] else (1920, 1080)

        img = img.resize((xres // 8, xres // 8))
        alpha = Image.new("RGBA", (xres, yres), (0, 0, 0, 0))
        loc = (img.size[0] * location, alpha.size[1] - img.size[1])
        alpha.paste(img, loc)
        alpha.save(output)

    except Exception as e:
        click.echo(f"Error: {e}")


if __name__ == "__main__":
    cli()
