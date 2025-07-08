def frame_reciever(num_cards, template_dir, files_dir):

    with open(template_dir / "stFrameReceiver.template", "r") as fr_t:
        template_string = fr_t.read()

        for card in range(num_cards):
            frame_reciever = template_string.replace("{card}", f"{(card + 1)}")
            frame_reciever = frame_reciever.replace("{num}", f"{(10*card):03d}")
            with open(files_dir / f"stFrameReceiver{card+1}.sh", "w") as fr_file:
                fr_file.write(frame_reciever)


def frame_reciever_json(num_cards, template_dir, files_dir):
    with open(template_dir / "fr.json.template", "r") as fr_js_t:
        template_string = fr_js_t.read()

        for card in range(num_cards):
            frame_reciever = template_string.replace("{port}", f"{(card + 50)}")
            frame_reciever = frame_reciever.replace("{buf}", f"{(card + 1)}")
            frame_reciever = frame_reciever.replace("{ready}", f"{(10 * card + 1):03d}")
            frame_reciever = frame_reciever.replace(
                "{release}", f"{(10 * card + 2):03d}"
            )
            with open(files_dir / f"fr{card+1}.json", "w") as fr_json_file:
                fr_json_file.write(frame_reciever)
