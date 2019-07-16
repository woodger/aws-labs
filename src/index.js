exports.handler = async (event, context) => {
	console.log("received event: %j", event);

	return {
		statusCode: 200,
		body: JSON.stringify({
			message: 'hello world'
		})
	};
};
