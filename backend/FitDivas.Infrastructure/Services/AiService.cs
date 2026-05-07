using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using FitDivas.Application.DTOs.AI;
using FitDivas.Application.Interfaces.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace FitDivas.Infrastructure.Services;

public class AiService(IConfiguration configuration, ILogger<AiService> logger) : IAiService
{
    private static readonly HashSet<string> _topicosPermitidos = new(StringComparer.OrdinalIgnoreCase)
    {
        "exercício", "exercicio", "treino", "série", "serie", "repetição", "repeticao",
        "musculação", "musculacao", "academia", "equipamento", "haltere", "barra", "anilha",
        "agachamento", "supino", "terra", "remada", "rosca", "tríceps", "biceps", "bicep",
        "peitoral", "costas", "ombro", "perna", "glúteo", "gluteo", "abdômen", "abdomen",
        "aquecimento", "alongamento", "cardio", "aeróbico", "aerobico", "postura", "execução",
        "execucao", "técnica", "tecnica", "carga", "peso", "musculo", "músculo", "força",
        "forca", "hipertrofia", "resistência", "resistencia", "mobilidade", "flexibilidade"
    };

    public async Task<AiChatResponseDto> ChatAsync(AiChatRequestDto dto)
    {
        if (!IsTopicoPermitido(dto.Pergunta))
        {
            return new AiChatResponseDto
            {
                Resposta = "Só posso ajudar com dúvidas sobre exercícios, execução de movimentos e equipamentos de academia. Para dietas, treinos personalizados ou outras questões, consulte um profissional. 😊"
            };
        }

        var apiKey = configuration["OpenAI:ApiKey"];
        if (string.IsNullOrEmpty(apiKey))
        {
            return new AiChatResponseDto
            {
                Resposta = GetRespostaLocal(dto.Pergunta)
            };
        }

        try
        {
            return await ChatWithOpenAiAsync(dto.Pergunta, apiKey);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Erro ao consultar IA");
            return new AiChatResponseDto { Resposta = GetRespostaLocal(dto.Pergunta) };
        }
    }

    private static bool IsTopicoPermitido(string pergunta)
    {
        var palavras = pergunta.Split(' ', StringSplitOptions.RemoveEmptyEntries);
        return palavras.Any(p => _topicosPermitidos.Contains(p.Trim('?', '!', '.', ',')));
    }

    private async Task<AiChatResponseDto> ChatWithOpenAiAsync(string pergunta, string apiKey)
    {
        using var client = new HttpClient();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);

        var body = new
        {
            model = "gpt-4o-mini",
            messages = new[]
            {
                new { role = "system", content = "Você é uma assistente fitness especializada em execução de exercícios e uso de equipamentos de academia. Responda de forma clara, objetiva e em português. Não crie treinos completos nem dietas. Foque apenas em tirar dúvidas pontuais sobre execução e equipamentos." },
                new { role = "user", content = pergunta }
            },
            max_tokens = 400,
            temperature = 0.5
        };

        var response = await client.PostAsync(
            "https://api.openai.com/v1/chat/completions",
            new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json"));

        response.EnsureSuccessStatusCode();

        var json = JsonDocument.Parse(await response.Content.ReadAsStringAsync());
        var resposta = json.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString() ?? "Não foi possível obter resposta.";

        return new AiChatResponseDto { Resposta = resposta };
    }

    private static string GetRespostaLocal(string pergunta) =>
        pergunta.ToLower() switch
        {
            var p when p.Contains("agachamento") =>
                "No agachamento, mantenha os pés na largura dos ombros, joelhos apontando para fora (na direção dos pés), desça até as coxas ficarem paralelas ao chão e mantenha o peito ereto durante todo o movimento.",
            var p when p.Contains("supino") =>
                "No supino, deite no banco com os pés apoiados no chão, segure a barra com pegada um pouco mais larga que a largura dos ombros, desça a barra controladamente até o peito e empurre para cima.",
            var p when p.Contains("rosca") =>
                "Na rosca direta, mantenha os cotovelos fixos ao lado do corpo, flexione o braço trazendo o peso em direção ao ombro. Evite balançar o tronco para ganhar impulso.",
            var p when p.Contains("terra") || p.Contains("levantamento terra") =>
                "No levantamento terra, posicione os pés na largura dos quadris, segure a barra com os braços por fora dos joelhos, mantenha a coluna neutra e empurre o chão com os pés ao subir.",
            _ => "Para uma execução correta dos exercícios, foque sempre na postura, controle o movimento nas duas fases (subida e descida), use uma carga adequada ao seu nível e, se possível, peça orientação de um profissional na academia."
        };
}
