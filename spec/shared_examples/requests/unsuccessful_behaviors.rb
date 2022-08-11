shared_examples 'when the user does not have permissions' do
  it 'returns 403 HTTP status code' do
    do_request

    expect(response).to be_forbidden
  end

  it 'does not return any data' do
    do_request

    expect(response.body).to eq ''
  end
end

shared_examples 'when the entity is unprocessable' do
  it 'returns 422 HTTP status code' do
    do_request

    expect(response).to be_unprocessable
  end

  it 'returns JSON with errors' do
    do_request

    expect(JSON.parse(response.body)).to eq({ errors: ['SOMETHING_WENT_WRONG'] }.as_json)
  end
end

shared_examples 'when a bad request' do
  it 'returns 400 HTTP status code' do
    do_request

    expect(response).to be_bad_request
  end

  it 'returns JSON with errors' do
    do_request

    expect(JSON.parse(response.body)).to eq({ errors: ['SOMETHING_WENT_WRONG'] }.as_json)
  end
end

shared_examples 'when the entity does not exist' do
  it 'returns 404 HTTP status code' do
    do_request

    expect(response).to be_not_found
  end

  it 'does not return any data' do
    do_request

    expect(response.body).to eq ''
  end
end
