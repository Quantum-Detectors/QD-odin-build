import string


def frame_processor(num_cards, template_dir, files_dir):
    with open(template_dir / "stFrameProcessor.template", "r") as fp_t:
        template_string = fp_t.read()

        for card in range(num_cards):
            frame_processor_str = template_string.replace("{card}", str(card + 1))
            frame_processor_str = frame_processor_str.replace(
                "{num}", f"{(10*card)+4:03d}"
            )
            with open(files_dir / f"stFrameProcessor{card+1}.sh", "w") as fp_file:
                fp_file.write(frame_processor_str)


def frame_processor_json(num_cards, template_dir, files_dir):
    with open(template_dir / "fp.json.template", "r") as fp_js_t:
        template_string = fp_js_t.read()
        letter = list(string.ascii_uppercase)

        for card in range(num_cards):
            frame_processor_json_str = template_string.replace(
                "{ready}", f"{(10*card)+1:03d}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{release}", f"{(10*card)+2:03d}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{meta}", f"{(10*card)+8:03d}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{lv_socket}", f"{card:02d}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{list_channels}", f"[{card*2}, {(card*2)+1}]"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{postfix}", f"_{letter[card]}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{chan_1}", f"{card*2}"
            )
            frame_processor_json_str = frame_processor_json_str.replace(
                "{chan_2}", f"{(card*2)+1}"
            )

            with open(files_dir / f"fp{card+1}.json", "w") as fp_json_file:
                fp_json_file.write(frame_processor_json_str)
