import unittest

from app import app


class FlaskAppTests(unittest.TestCase):

    def setUp(self):
        self.client = app.test_client()

    def test_index(self):
        response = self.client.get("/")

        self.assertEqual(response.status_code, 200)

        self.assertIn(
            b"Application successfully deployed!",
            response.data
        )

    def test_health(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)

        data = response.get_json()

        self.assertEqual(data["status"], "ok")

        self.assertEqual(
            data["service"],
            "lab10-flask"
        )

        self.assertIn("version", data)


if __name__ == "__main__":
    unittest.main()
