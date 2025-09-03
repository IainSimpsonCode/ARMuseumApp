export const serverHealthCheck = async (req, res) => {
  return res.status(200).json({ message: "Server is OK and online." })
}