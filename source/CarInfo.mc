const ID_FIELD = "id";
const MAKE_FIELD = "make";
const MODEL_FIELD = "model";

function createCar(id, make, model) {
    return {ID_FIELD => id, MAKE_FIELD => make, MODEL_FIELD => model};
}