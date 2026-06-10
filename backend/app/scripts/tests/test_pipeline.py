import requests
import tempfile
import os
import base64


def display_image(image_base64, mime_type=None):
    image_bytes = base64.b64decode(image_base64)

    extension = ".png"

    if mime_type:
        if "jpeg" in mime_type or "jpg" in mime_type:
            extension = ".jpg"
        elif "png" in mime_type:
            extension = ".png"

    temp_path = tempfile.mktemp(suffix=extension)

    with open(temp_path, "wb") as f:
        f.write(image_bytes)

    os.startfile(temp_path)


def main():
    print("=================================================")
    print("Testing pipeline...")
    print("=================================================")

    print("Wylosowany zestaw:")

    try:
        response = requests.get(
            "http://localhost:8000/api/set-of-questions"
        )

        data = response.json()

        for key in ["question1", "question2"]:
            question_data = data.get(key)

            if not question_data:
                continue

            print(f"\n===== {key.upper()} =====")
            print(question_data.get("question"))

            if question_data.get("question_type") == "image":
                image_base64 = question_data.get("image_base64")

                if image_base64:
                    display_image(
                        image_base64=image_base64,
                        mime_type=question_data.get("image_mime_type")
                    )

    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()